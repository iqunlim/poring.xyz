import { z, ZodError } from "zod";

const apiUrl = import.meta.env.VITE_API_URL

if (!apiUrl) {
    throw new Error("VITE_API_URL is not defined");
}


export class ApiError extends Error {
    source: string;
    statusText: string;
    constructor(source: string, statusText: string, message = "An API error occurred") {
        super(message);
        this.source = source;
        this.statusText = statusText;
        this.name = "ApiError";
    }

    toString() {
        return `[${this.source} ${this.statusText}] ${this.message}`;
    }
}

// TODO: Explore input and output types in order to make
// not all of these optional
const ApiDataZod = z.object({
    url: z.string().url().optional(),
    fields: z.object({
        "Content-Type": z.string(),
        key: z.string(),
        "x-amz-algorithm": z.string(),
        "x-amz-credential": z.string(),
        "x-amz-date": z.string(),
        "x-amz-security-token": z.string(),
        policy: z.string(),
        "x-amz-signature": z.string(),
    }).optional(),
    imageUrl: z.string().url().optional(),
    error: z.string().optional()
});

export type ApiData = z.infer<typeof ApiDataZod>;

const validateApiResponse = (ResponseData: unknown) => {
    const parsedData = ApiDataZod.parse(ResponseData);
    return parsedData;
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
            return data;
        }).catch((err) => {
            if (err instanceof Error) {
                throw new ApiError("setSignedS4Url.ApiReturn", "API Error", err.message);
            } else if (err instanceof ZodError) {
                throw new ApiError("Zod", "Zod Validation error", err.message);
            } else {
                throw new Error(`Unknown: Error: ${err}`);
            }
        });
}

export async function putSignedS3Object(file: File, SignedS3Response: ApiData, url: string) {
    const postData = new FormData();
    if (SignedS3Response.fields) {
        Object.entries(SignedS3Response.fields).forEach(([key, val]) => {
            postData.append(key, val as keyof typeof SignedS3Response.fields);
        })
        postData.append('file', file);
        return fetch(url, { method: "POST", body: postData });
    } else {
        throw new TypeError("SignedS3Response was undefined, expected ApiData");
    }
}