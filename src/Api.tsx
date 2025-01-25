const apiUrl = "https://dd0zurzvoj.execute-api.us-east-2.amazonaws.com"


export type APIDataFields = {
    "Content-Type": string;
    key: string;
    "x-amz-algorithm": string;
    "x-amz-credential": string;
    "x-amz-date": string;
    "x-amz-security-token": string;
    policy: string;
    "x-amz-signature": string;
}

export type APIData = {
    url: string;
    fields: APIDataFields
}

export interface ApiResponse {
    data: APIData
    url: string;
    error: string;
}




export async function getSignedS3Url(file: File) {
    const url = `${apiUrl}/v1/sign-s3?fileName=${file.name}&fileType=${file.type}&t=${file.size}`

    const ret = await fetch(url)
    if (ret.ok) {
        return ret
    } else {
        console.log(ret.status)
        throw new Error("Bad request")
    }
}

export async function putSignedS3Object(file: File, SignedS3Response: ApiResponse, url: string) {
    console.log("url:", url)
    const postData = new FormData();
    const fieldData = SignedS3Response.data.fields
    for (const key in fieldData) {
        const val: string = SignedS3Response.data.fields[key as keyof APIDataFields]
        postData.append(key, val)
    }

    postData.append('file', file)

    console.log(postData)
    const res = await fetch(url, { method: "POST", body: postData })
    return res
}