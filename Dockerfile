FROM postgres:latest

COPY data.sql /docker-entrypoint-initdb.d/

ENV POSTGRES_DB test2
ENV POSTGRES_USER user2
ENV POSTGRES_PASSWORD haslo

EXPOSE 5432

CMD ["postgres"]
