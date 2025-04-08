import { z, ZodError } from "zod";
import { fileTypeFromBlob } from "file-type";

export const excludedMimeTypes = [
  "application/x-msdownload", // .exe, .dll
  "application/x-sh", // .sh
  "application/x-bat", // .bat
  "application/x-msdos-program", // .com
  "application/x-python", // .py
  "application/x-php", // .php
  "application/x-perl", // .pl
  "application/x-java-archive", // .jar
  "application/x-ms-shortcut", // .lnk
  "application/x-msdos-windows", // .sys
  "application/x-msdos-program", // .drv
  "application/x-msi", // .msi, .msp
  "application/octet-stream", // generic binary files
  "text/x-shellscript", // .sh, .bash
  "application/json", // sometimes restricted due to API security concerns
  "application/x-dosexec", // Windows executable binaries
  "application/x-httpd-php", // .php
  "text/html", // .html, .htm (to prevent phishing attempts)
  "application/javascript", // .js
  "application/x-java", // .class
  "application/iso", // .iso
  "application/x-bittorrent", // .torrent
];

const apiUrl = import.meta.env.VITE_API_URL;

if (!apiUrl) {
  throw new Error("VITE_API_URL is not defined");
}

export class ApiError extends Error {
  source: string;
  statusText: string;
  constructor(
    source: string,
    statusText: string,
    message = "An API error occurred"
  ) {
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
  fields: z
    .object({
      "Content-Type": z.string(),
      key: z.string(),
      "x-amz-algorithm": z.string(),
      "x-amz-credential": z.string(),
      "x-amz-date": z.string(),
      "x-amz-security-token": z.string(),
      policy: z.string(),
      "x-amz-signature": z.string(),
    })
    .optional(),
  fileUrl: z.string().url().optional(),
  error: z.string().optional(),
});

export type ApiData = z.infer<typeof ApiDataZod>;

const validateApiResponse = (ResponseData: unknown) => {
  const parsedData = ApiDataZod.parse(ResponseData);
  return parsedData;
};

// These two functions can be used for S3 uploading securely. The new API uses R2.
export async function getSignedS3Url(file: File) {
  const url = `${apiUrl}?fileName=${encodeURIComponent(
    file.name
  )}&fileType=${encodeURIComponent(file.type)}&t=${file.size}`;
  return fetch(url)
    .then((data) => data.json())
    .then(validateApiResponse)
    .then((data) => {
      if (data.error) {
        throw new Error(data.error);
      }
      return data;
    })
    .catch((err) => {
      if (err instanceof Error) {
        throw new ApiError(
          "setSignedS4Url.ApiReturn",
          "API Error",
          err.message
        );
      } else if (err instanceof ZodError) {
        throw new ApiError("Zod", "Zod Validation error", err.message);
      } else {
        throw new Error(`Unknown: Error: ${err}`);
      }
    });
}

export async function putSignedS3Object(
  file: File,
  SignedS3Response: ApiData,
  url: string
) {
  const postData = new FormData();
  if (SignedS3Response.fields) {
    Object.entries(SignedS3Response.fields).forEach(([key, val]) => {
      postData.append(key, val as keyof typeof SignedS3Response.fields);
    });
  } else {
    console.debug("putSignedS3Object: No fields in response, skipping");
  }
  postData.append("file", file);
  return fetch(url, { method: "POST", body: postData });
}

// In the new API, we can simply POST the file.
// However, the API has a max limit of 100MB files.
export async function putR2Object(file: File) {
  const fileType = await fileTypeFromBlob(file);
  const fileTypeEncode = fileType?.mime ?? file.type;

  const url = `${apiUrl}?fileName=${encodeURIComponent(
    file.name
  )}&fileType=${encodeURIComponent(fileTypeEncode)}`;
  if (!file) {
    throw new Error("No file provided");
  }
  const postData = new FormData();
  postData.append("file", file);
  postData.append("test", "Testing");
  return fetch(url, { method: "POST", body: postData })
    .then((data) => data.json())
    .then(validateApiResponse);
}
