FROM scratch AS downloader
WORKDIR /repo
ADD https://codeberg.org/fmctf/xiolot.git#latest-release .

FROM eclipse-temurin:25-jdk-alpine AS builder
RUN $JAVA_HOME/bin/jlink --add-modules java.base --strip-debug --no-man-pages --no-header-files --compress=2 --output /javaruntime
WORKDIR /opt/app
COPY --from=downloader /repo/.mvn ./.mvn
COPY --from=downloader /repo/mvnw ./mvnw
COPY --from=downloader /repo/pom.xml ./pom.xml
RUN ["/opt/app/mvnw", "dependency:go-offline"]
COPY --from=downloader /repo .
RUN ["/opt/app/mvnw", "package"]
RUN mv -v ./target/xiolot-server-*-fat-jar.jar ./target/xiolot.jar

FROM alpine
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=builder /javaruntime $JAVA_HOME
COPY --from=builder /opt/app/target/xiolot.jar /opt/app/xiolot.jar
WORKDIR /data
CMD ["java", "-jar", "/opt/app/xiolot.jar"]