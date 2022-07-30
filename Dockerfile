FROM sralloza/openjdk:11-jre as build

WORKDIR /home/gradle

COPY gradle/ /home/gradle/gradle/
COPY build.gradle settings.gradle gradlew /home/gradle/
COPY src/ /home/gradle/src/

RUN ./gradlew build
RUN rm /home/gradle/build/libs/*-plain.jar
RUN ls -l /home/gradle/build/libs

FROM sralloza/openjdk:11-jre

RUN apt update && \
    apt upgrade -y && \
    apt install locales -y

RUN sed -i '/es_ES.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG es_ES.UTF-8
ENV LC_ALL es_ES.UTF-8
ENV TZ Europe/Madrid

COPY utils/wait-for-it.sh /app/wait-for-it.sh
COPY utils/entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/*.sh

EXPOSE 8080

COPY --from=build /home/gradle/build/libs/*.jar /app/chore-management-api.jar

ENTRYPOINT [ "/app/entrypoint.sh" ]
