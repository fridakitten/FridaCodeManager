//
// main.c
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>

#define PACKET_SIZE 64
#define DEFAULT_COUNT 4
#define DEFAULT_INTERVAL 1

int sockfd;
char *target;
struct sockaddr_in dest_addr;
int packet_size = PACKET_SIZE;
int count = DEFAULT_COUNT;
int interval = DEFAULT_INTERVAL;
int ttl = 64;
int verbose = 0;
int sent_count = 0;
int received_count = 0;

void usage() {
    printf("Usage: ping [-c count] [-i interval] [-s packetsize] [-t ttl] [-v] destination\n");
    exit(EXIT_FAILURE);
}

unsigned short checksum(void *b, int len) {
    unsigned short *buf = b;
    unsigned int sum = 0;
    unsigned short result;

    for (sum = 0; len > 1; len -= 2) {
        sum += *buf++;
    }
    if (len == 1) {
        sum += *(unsigned char *)buf;
    }
    sum = (sum >> 16) + (sum & 0xFFFF);
    sum += (sum >> 16);
    result = ~sum;
    return result;
}

void send_ping() {
    struct icmp icmp_packet;
    char send_buffer[PACKET_SIZE];
    int packet_size = sizeof(struct icmp);

    icmp_packet.icmp_type = ICMP_ECHO;
    icmp_packet.icmp_code = 0;
    icmp_packet.icmp_id = getpid();
    icmp_packet.icmp_seq = sent_count++;
    memset(&icmp_packet.icmp_data, 0xa5, sizeof(icmp_packet.icmp_data));
    gettimeofday((struct timeval *)&icmp_packet.icmp_data, NULL);

    icmp_packet.icmp_cksum = 0;
    icmp_packet.icmp_cksum = checksum(&icmp_packet, sizeof(icmp_packet));

    if (sendto(sockfd, &icmp_packet, sizeof(icmp_packet), 0, (struct sockaddr *)&dest_addr, sizeof(dest_addr)) <= 0) {
        perror("sendto");
    }
}

void receive_ping() {
    char recv_buffer[PACKET_SIZE];
    int addr_len = sizeof(dest_addr);
    struct ip *ip_hdr;
    struct icmp *icmp_hdr;
    struct timeval *send_time, recv_time, current_time;
    int ip_header_len;

    if (recvfrom(sockfd, recv_buffer, sizeof(recv_buffer), 0, (struct sockaddr *)&dest_addr, (socklen_t *)&addr_len) <= 0) {
        perror("recvfrom");
        return;
    }

    ip_hdr = (struct ip *)recv_buffer;
    ip_header_len = ip_hdr->ip_hl * 4;
    icmp_hdr = (struct icmp *)(recv_buffer + ip_header_len);

    if (icmp_hdr->icmp_type == ICMP_ECHOREPLY) {
        gettimeofday(&recv_time, NULL);
        send_time = (struct timeval *)&icmp_hdr->icmp_data;

        timersub(&recv_time, send_time, &current_time);
        printf("%d bytes from %s: icmp_seq=%d ttl=%d time=%.2f ms\n",
               packet_size, inet_ntoa(dest_addr.sin_addr), icmp_hdr->icmp_seq, ip_hdr->ip_ttl,
               current_time.tv_sec * 1000.0 + current_time.tv_usec / 1000.0);

        received_count++;
    }
}

void signal_handler(int signo) {
    if (signo == SIGINT) {
        printf("\n--- %s ping statistics ---\n", target);
        printf("%d packets transmitted, %d received, %.0f%% packet loss\n",
               sent_count, received_count, ((sent_count - received_count) / (float)sent_count) * 100.0);
        close(sockfd);
        exit(EXIT_SUCCESS);
    }
}

int main(int argc, char *argv[]) {
    int opt;

    if (argc < 2) {
        usage();
    }

    while ((opt = getopt(argc, argv, "c:i:s:t:v")) != -1) {
        switch (opt) {
            case 'c':
                count = atoi(optarg);
                break;
            case 'i':
                interval = atoi(optarg);
                break;
            case 's':
                packet_size = atoi(optarg);
                if (packet_size <= 0) {
                    fprintf(stderr, "Invalid packet size\n");
                    exit(EXIT_FAILURE);
                }
                break;
            case 't':
                ttl = atoi(optarg);
                break;
            case 'v':
                verbose = 1;
                break;
            default:
                usage();
        }
    }

    if (optind >= argc) {
        usage();
    }

    target = argv[optind];

    sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
    if (sockfd < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }

    struct timeval timeout;
    timeout.tv_sec = 1;
    timeout.tv_usec = 0;

    if (setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, (const char *)&timeout, sizeof(timeout)) < 0) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }

    if (setsockopt(sockfd, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl)) < 0) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }

    dest_addr.sin_family = AF_INET;
    dest_addr.sin_addr.s_addr = inet_addr(target);

    signal(SIGINT, signal_handler);

    printf("PING %s (%s) %d bytes of data.\n", target, inet_ntoa(dest_addr.sin_addr), packet_size);

    while (sent_count < count || count == 0) {
        send_ping();
        receive_ping();
        sleep(interval);
    }

    printf("\n--- %s ping statistics ---\n", target);
    printf("%d packets transmitted, %d received, %.0f%% packet loss\n",
           sent_count, received_count, ((sent_count - received_count) / (float)sent_count) * 100.0);

    close(sockfd);

    return EXIT_SUCCESS;
}