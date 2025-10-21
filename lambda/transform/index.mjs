import {S3Client, GetObjectCommand} from "@aws-sdk/client-s3";

const s3 = new S3Client({})

export const handler = async (input) => {
    const bucket = input?.bucket
    const rawKey = input?.key

    if (!bucket || !rawKey) {
        throw new Error("Missing 'bucket' or 'key' in input. Expected { bucket, rawKey }");
    }

    const resultStream = await s3.send(new GetObjectCommand({Bucket: bucket, Key: rawKey}));
    const stringEvent = await resultStream.Body.transformToString("utf-8");
    const jsonRawEvent = JSON.parse(stringEvent);

    const transformedEvent = {
        id: jsonRawEvent.id,
        vorname: jsonRawEvent.firstName,
        nachname: jsonRawEvent.lastName,
        status: jsonRawEvent.status,
    };

    return {
        bucket: bucket,
        rawKey: rawKey,
        id: transformedEvent.id,
        event: transformedEvent,
        millis: Date.now()
    };
};
