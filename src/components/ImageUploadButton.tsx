import { useActionState, useEffect, useRef } from "react";
import { ApiError, getSignedS3Url, putSignedS3Object } from "../Api";
import mime from "mime-types";

export default function ImageUploadForm({ currentFileUrl, currentFileSetter }: { currentFileUrl: string, currentFileSetter: React.Dispatch<React.SetStateAction<string>> }) {

    const formRef = useRef<HTMLFormElement | null>(null);
    const inputRef = useRef<HTMLInputElement | null>(null);

    const action = async (_: string | null | undefined, formData: FormData) => {
        const file = formData.get("image") as File;
        if (file) {
            try {
                const SignedData = await getSignedS3Url(file);
                if (SignedData && SignedData.url) {
                    putSignedS3Object(file, SignedData, SignedData.url).then(() => {
                        if (SignedData.imageUrl) {
                            currentFileSetter(SignedData.imageUrl);
                        }
                    })
                    return "Uploaded";
                } else {
                    return "There was an error. Please try again later";
                }
            } catch (error) {
                if (error instanceof ApiError) {
                    console.error(error.toString());
                } else if (error instanceof Error) {
                    console.error(error.message);
                }
                return "There was an error. Please try again later";
            }
        } else {
            return "Please select a file";
        }
    }

    const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        event.preventDefault();
        if (event.target.files && event.target.files.length > 0 && formRef.current) {
            formRef.current.requestSubmit();
        }
    }

    const [actionState, formAction, isPending] = useActionState(action, null);

    useEffect(() => {
        window.addEventListener('keydown', async (e: KeyboardEvent) => {
            if (e.ctrlKey && e.key === "v") {
                try {
                    const clipboardItems = await navigator.clipboard.read();
                    for (const clipboardItem of clipboardItems) {
                        for (const type of clipboardItem.types) {
                            // If it's an image...
                            if (type.match(/image\/\w+/i)) {
                                const blob = await clipboardItem.getType(type);
                                const file = new File([blob],
                                    `${window.crypto.randomUUID().slice(0, 8)}.${mime.extension(blob.type)}`,
                                    { type: blob.type });
                                // The form submit action controls the reactivity of the page
                                // forcing the input element to have a file in it and then
                                // submitting the form allows that interactivity to work even with ctrl+v
                                const dataTransfer = new DataTransfer();
                                dataTransfer.items.add(file);
                                if (inputRef.current && formRef.current) {
                                    inputRef.current.files = dataTransfer.files;
                                    formRef.current.requestSubmit();
                                    return;
                                }
                            }
                        }
                    }
                } catch (err) {
                    if (err instanceof Error) {
                        console.error(err.name, err.message);
                    }
                }
            }
        })
    }, [])

    return (
        <>
            <h1 className="text-3xl font-bold">{actionState ? actionState : "Choose a file..."}</h1>
            {isPending && <h2 className="text-2xl font-bold">Uploading...</h2>}
            <form className="min-w-full mb-4" ref={formRef} action={formAction}>
                <input ref={inputRef} type="file" id="img" name="image" accept="image/*" onChange={handleFileChange} hidden disabled={isPending} />
                <label htmlFor="img" className={`block font-bold py-2 cursor-pointer text-center rounded-full shadow-md bg-red-200 ${isPending ? "bg-slate-800 opacity-50" : "hover:bg-red-300"}`}>{`Upload ${currentFileUrl ? "Another" : ""} Image`}</label>
            </form>
        </>
    )
}