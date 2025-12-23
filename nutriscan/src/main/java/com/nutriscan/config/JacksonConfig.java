package com.nutriscan.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalTimeSerializer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

@Configuration
public class JacksonConfig {

    @Bean
    @Primary
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();

        JavaTimeModule module = new JavaTimeModule();

        // Date format: yyyy-MM-dd
        module.addDeserializer(LocalDate.class,
            new LocalDateDeserializer(DateTimeFormatter.ISO_LOCAL_DATE));
        module.addSerializer(LocalDate.class,
            new LocalDateSerializer(DateTimeFormatter.ISO_LOCAL_DATE));

        // Time format: HH:mm:ss
        module.addDeserializer(LocalTime.class,
            new LocalTimeDeserializer(DateTimeFormatter.ISO_LOCAL_TIME));
        module.addSerializer(LocalTime.class,
            new LocalTimeSerializer(DateTimeFormatter.ISO_LOCAL_TIME));

        mapper.registerModule(module);
        mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

        return mapper;
    }
}

