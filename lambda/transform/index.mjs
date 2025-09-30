import {S3Client, GetObjectCommand} from "@aws-sdk/client-s3";

const s3 = new S3Client({})

const STAGING_BUCKET = process.env.STAGING_BUCKET;

export const handler = async (input) => {
    const rawEventId = `raw-events/${input?.eventId}.json`

    // TODO: Einzelnes JSON Rohevent aus S3 lesen
    // new GetObjectCommand({Bucket: STAGING_BUCKET, Key: rawEventId})
    // transformToString("utf-8")
    // JSON.parse()

    // TODO: Rohevent in das neue Schema überführen
    // from: { id, firstName, lastName, status }
    // to:   { id, vorname, nachname, status }

    // TODO: Bucket, Rohevent-ID, transformiertes Event, Millis an nächsten Step übergeben
    // return: bucket, rawId, transformedId, event, millis
    return null;
};