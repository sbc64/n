version: "3.7"
services:
  app:
    image: {image}
    dns: "{DNS server to use}"
    networks:
      tunneled0: {}
networks:
  tunneled0:
    ipam:
      config:
        - subnet: 10.123.0.0/16

Make tunneled0 the wg-quick configruation
