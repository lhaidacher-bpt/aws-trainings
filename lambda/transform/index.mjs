import {S3Client, GetObjectCommand} from "@aws-sdk/client-s3";

const s3 = new S3Client({})

const STAGING_BUCKET = process.env.STAGING_BUCKET;

export const handler = async (input) => {
    const rawEventId = `raw-events/${input?.eventId}.json`
    const res = await s3.send(new GetObjectCommand({Bucket: STAGING_BUCKET, Key: rawEventId}));
    const text = await res.Body.transformToString("utf-8");
    const rawEvent = JSON.parse(text);

    const transformedEvent = {
        id: rawEvent.id,
        vorname: rawEvent.firstName,
        nachname: rawEvent.lastName,
        status: rawEvent.status,
    };

    return {
        bucket: STAGING_BUCKET,
        rawId: rawEventId,
        transformedId: transformedEvent.id,
        event: transformedEvent,
        millis: Date.now()
    };
};
