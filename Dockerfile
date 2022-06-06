FROM sralloza/openjdk:11-jre as build

WORKDIR /home/gradle

COPY gradle/ /home/gradle/gradle/
COPY build.gradle settings.gradle gradlew /home/gradle/
COPY src/ /home/gradle/src/

RUN ./gradlew build

FROM sralloza/openjdk:11-jre

COPY utils/wait-for-it.sh /app/wait-for-it.sh
COPY utils/entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/*.sh

EXPOSE 8080

COPY --from=build /home/gradle/build/libs/*.jar /app/chore-management-api.jar

ENTRYPOINT [ "/app/entrypoint.sh" ]
