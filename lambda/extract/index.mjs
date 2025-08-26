import {S3Client, PutObjectCommand} from "@aws-sdk/client-s3";
import {SQSClient, SendMessageCommand} from "@aws-sdk/client-sqs";

const s3 = new S3Client({});
const sqs = new SQSClient({});

const LANDING_BUCKET = process.env.LANDING_BUCKET;
const SPLITTER_QUEUE_URL = process.env.SPLITTER_QUEUE_URL;
const LOG_BUCKET = process.env.LOG_BUCKET || null;

export const handler = async (event) => {
    const failures = [];

    for (const message of event.Records) {
        try {
            const body = typeof message.body === "string" ? JSON.parse(message.body) : message.body;

            // Originale Nachricht als NDJSON speichern
            const landingKey = `raw-message/${message.messageId}.ndjson`;
            await s3.send(new PutObjectCommand({
                Bucket: LANDING_BUCKET,
                Key: landingKey,
                Body: JSON.stringify(body) + "\n",
                ContentType: "application/x-ndjson",
            }));

            // Audit-Drop (nicht kritisch für Erfolg)
            if (LOG_BUCKET) {
                const auditKey = `landing-audit/${message.messageId}.json`;
                try {
                    await s3.send(new PutObjectCommand({
                        Bucket: LOG_BUCKET,
                        Key: auditKey,
                        Body: JSON.stringify({
                            service: "extract",
                            ts: new Date().toISOString(),
                            messageId: message.messageId,
                            storedKey: landingKey
                        }),
                        ContentType: "application/json",
                    }));
                } catch (e) {
                    console.warn("audit drop failed", message.messageId, String(e));
                }
            }

            // 1:1 weiterleiten an Splitter-Queue
            await sqs.send(new SendMessageCommand({
                QueueUrl: SPLITTER_QUEUE_URL,
                MessageBody: JSON.stringify(body),
            }));
        } catch (e) {
            console.error("extract failed", message?.messageId, e);
            failures.push({itemIdentifier: message?.messageId});
        }
    }

    return {batchItemFailures: failures};
};
