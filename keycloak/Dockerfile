FROM quay.io/keycloak/keycloak:latest AS builder

# Configure a database vendor
ENV KC_DB=mariadb
ADD --chown=keycloak:keycloak --chmod=644 https://dlm.mariadb.com/3978472/Connectors/java/connector-java-3.5.1/mariadb-java-client-3.5.1.jar /opt/keycloak/providers/mariadb-java-client-3.5.1.jar

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -ext "SAN:c=DNS:keycloak,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY keycloak.conf /opt/keycloak/conf/keycloak.conf
COPY custom_theme /opt/keycloak/themes/custom_theme

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"]