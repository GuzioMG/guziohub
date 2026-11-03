FROM scratch AS downloader
WORKDIR /repo
ADD https://codeberg.org/fmctf/xiolot.git#latest-release .

FROM eclipse-temurin:25-jdk-alpine AS builder
WORKDIR /builder
COPY --from=downloader /repo/.mvn ./.mvn
COPY --from=downloader /repo/mvnw ./mvnw
COPY --from=downloader /repo/pom.xml ./pom.xml
RUN ["./mvnw", "dependency:go-offline"]
COPY --from=downloader /repo .
RUN ["./mvnw", "package"]
RUN mv -v ./target/xiolot-server-*-fat-jar.jar ./target/xiolot.jar

FROM eclipse-temurin:25-jdk-alpine AS jbuilder
RUN $JAVA_HOME/bin/jlink --add-modules java.base,java.xml,java.sql --strip-debug --no-man-pages --no-header-files --output /javaruntime

FROM alpine
ENV JAVA_HOME=/opt/jre25
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=jbuilder /javaruntime $JAVA_HOME
COPY --from=builder /builder/target/xiolot.jar /opt/app/xiolot.jar
WORKDIR /opt/app/config
CMD ["java", "-jar", "../xiolot.jar"]