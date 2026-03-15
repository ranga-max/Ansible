package io.confluent.examples.clients.basicavro;

import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;


import java.time.Duration;
import java.util.Properties;
import java.util.Properties;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.FileInputStream;
import java.io.InputStream;

public class ProducerCsfle {

    private static final String TOPIC = "customer";

    public static void main(final String[] args) throws Exception {

        final Properties props = buildProducerProps();
        // Avro schema (must match what you registered in SR)
       final String schemaJson =
            "{ \"namespace\": \"demo\", \"name\": \"Customer\", \"type\": \"record\", " +
            "  \"fields\": [" +
            "    {\"name\": \"id\", \"type\": \"string\"}," +
            "    {\"name\": \"ssn\", \"type\": \"string\", \"confluent:tags\": [\"PII\"]}," +
            "    {\"name\": \"name\", \"type\": \"string\"}" +
            "  ]" +
            "}";

        final Schema schema = new Schema.Parser().parse(schemaJson);    
            
        final KafkaProducer<String, GenericRecord> producer = new KafkaProducer<>(props);

        try {
            for (int i = 0; i < 5; i++) {
                final GenericRecord rec = new GenericData.Record(schema);
                rec.put("id", "cust-" + i);
                rec.put("ssn", "123-45-67" + i);  // PII field – encrypted client-side
                rec.put("name", "Customer " + i);

                final ProducerRecord<String, GenericRecord> record =
                    new ProducerRecord<>(TOPIC, rec.get("id").toString(), rec);

                producer.send(record, (metadata, exception) -> {
                    if (exception != null) {
                        exception.printStackTrace();
                    } else {
                        System.out.printf("Produced record to %s-%d@%d key=%s%n",
                                metadata.topic(), metadata.partition(),
                                metadata.offset(), record.key());
                    }
                });
            }
        } finally {
            producer.flush();
            producer.close(Duration.ofSeconds(5));
        }
    }

    private static Properties buildProducerProps() {
        final Properties props = new Properties();

        try (InputStream input = ProducerExample.class.getClassLoader().getResourceAsStream("prodconfig.properties")) {
            if (input == null) {
                System.err.println("Error: 'prodconfig.properties' not found in resources.");
            }
            props.load(input);
        } catch (final IOException e) {
            // Code to handle the exception
            System.err.println("An I/O error occurred: " + e.getMessage());
            e.printStackTrace(); 
        }

        // --- Kafka cluster ---
        //props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,
         //         "<BOOTSTRAP_SERVERS>"); // e.g. pkc-xxxxx.us-east-1.aws.confluent.cloud:9092
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,
                 StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
                  "io.confluent.kafka.serializers.KafkaAvroSerializer");

        // --- Confluent Cloud auth (if using CCloud) ---
        // props.put("security.protocol", "SASL_SSL");
        // props.put("sasl.mechanism", "PLAIN");
        // props.put("sasl.jaas.config",
        //     "org.apache.kafka.common.security.plain.PlainLoginModule required " +
        //     "username=\"<CLOUD_API_KEY>\" password=\"<CLOUD_API_SECRET>\";");

        // --- Schema Registry auth ---
        //props.put("schema.registry.url", "<SR_URL>"); // e.g. https://psrc-xxxxx.us-east-2.aws.confluent.cloud
        //props.put("basic.auth.credentials.source", "USER_INFO");
        //props.put("schema.registry.basic.auth.user.info",
         //         "<SR_API_KEY>:<SR_API_SECRET>");

        // --- CSFLE AWS non-shared KMS: client provides KMS creds ---
        // These let the FieldEncryptionExecutor call AWS KMS; SR/DEK registry never see them.
        props.put("rule.executors._default_.param.access.key.id",
                  "xxx");
        props.put("rule.executors._default_.param.secret.access.key",
                  "yyy");

        // We manually registered schema + rule; use latest version
        props.put("auto.register.schemas", "false");
        props.put("use.latest.version", "true");

        return props;
    }
}
