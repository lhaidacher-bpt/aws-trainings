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

            // TODO: Originale Nachricht als NDJSON speichern
            // Bucket-Key => raw-message/${message.messageId}.jsonl
            // Nachricht in Landing-Bucket speichern: Body => SON.stringify(body) + "\n"
            // Tipp: PutObjectCommand()

            // TODO: Audit-Drop (nicht kritisch für Erfolg)
            // Wenn LOG_BUCKET gegeben: Audit-Drop-Log in Logs-Bucket speichern
            // Bucket-Key => landing-audit/${message.messageId}.json
            // Nachricht speicher: Body => JSON.stringify({ service: "extract", ts: new Date().toISOString(), messageId: message.messageId, storedKey: landingKey})
            // Tipp: PutObjectCommand()

            // TODO: 1:1 weiterleiten an Splitter-Queue
            // Tipp: SendMessageCommand
        } catch (e) {
            console.error("extract failed", message?.messageId, e);
            failures.push({itemIdentifier: message?.messageId});
        }
    }

    return {batchItemFailures: failures};
};
