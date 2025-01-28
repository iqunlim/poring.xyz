import { z, ZodError } from "zod";

//TODO: Explore options to set this on the web server more dynamically.
const apiUrl = "https://dd0zurzvoj.execute-api.us-east-2.amazonaws.com"

const ApiDataZod = z.object({
    url: z.string().url(),
    fields: z.object({
        "Content-Type": z.string(),
        key: z.string(),
        "x-amz-algorithm": z.string(),
        "x-amz-credential": z.string(),
        "x-amz-date": z.string(),
        "x-amz-security-token": z.string(),
        policy: z.string(),
        "x-amz-signature": z.string(),
    }),
    imageUrl: z.string().url(),
    error: z.string().optional()
});

export type ApiData = z.infer<typeof ApiDataZod>

const validateApiResponse = (ResponseData: unknown) => {
    const parsedData = ApiDataZod.parse(ResponseData);
    return parsedData
}

export async function getSignedS3Url(file: File) {
    const url = `${apiUrl}/v1/sign-s3?fileName=${encodeURIComponent(file.name)}&fileType=${encodeURIComponent(file.type)}&t=${file.size}`;
    return fetch(url)
        .then(data => data.json())
        .then(validateApiResponse)
        .then(data => {
            if (data.error) {
                throw new Error(data.error);
            }
            return data
        }).catch((err) => {
            //TODO: special logging handlers for each type of error
            if (err instanceof Error) {
                console.log("Error getting Signed S3 Url");
                console.error(err);
            } else if (err instanceof ZodError) {
                console.log("Error validating API response");
                console.error(err);
            } else {
                console.error(`Unknown error: ${err}`);
            }
        });
}

export async function putSignedS3Object(file: File, SignedS3Response: ApiData, url: string) {
    const postData = new FormData();
    Object.entries(SignedS3Response.fields).forEach(([key, val]) => {
        postData.append(key, val as keyof typeof SignedS3Response.fields);
    })
    postData.append('file', file);
    return fetch(url, { method: "POST", body: postData });
}