import {S3Client, PutObjectCommand} from "@aws-sdk/client-s3";

const s3 = new S3Client({});

const STAGING_BUCKET = process.env.STAGING_BUCKET; // required

export const handler = async (event) => {
    const failures = [];

    for (const record of event.Records) {
        try {
            const msg = typeof record.body === "string" ? JSON.parse(record.body) : record.body;
            const events = Array.isArray(msg?.events) ? msg.events : null;
            if (!events) throw new Error("events must be an array");

            // TODO: Je Event als JSON unter raw-events/<eventId>.json speichern
            // Bucket-Key => raw-events/${id}.json
            // Nachricht in Staging-Bucket speichern: Body => JSON.stringify(event)
            // Tipp: PutObjectCommand()
        } catch (e) {
            console.error("splitter failed", record?.messageId, e);
            failures.push({itemIdentifier: record?.messageId});
        }
    }

    return {batchItemFailures: failures};
};
