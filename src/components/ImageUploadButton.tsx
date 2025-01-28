import { useActionState, useRef } from "react";
import { getSignedS3Url, putSignedS3Object } from "../Api";

export default function ImageUploadForm({ currentFileUrl, currentFileSetter }: { currentFileUrl: string, currentFileSetter: React.Dispatch<React.SetStateAction<string>> }) {

    const formRef = useRef<HTMLFormElement | null>(null);

    const action = async (_: string | null | undefined, formData: FormData) => {
        const file = formData.get("image") as File;
        if (file) {
            const SignedData = await getSignedS3Url(file);
            if (SignedData) {
                putSignedS3Object(file, SignedData, SignedData.url).then(() => {
                    currentFileSetter(SignedData.imageUrl);

                })
                return "Uploaded"
            } else {
                return "There was an error. Please try again later"
            }
        } else {
            return "Please select a file"
        }
    }

    const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        event.preventDefault();
        if (event.target.files && event.target.files.length > 0 && formRef.current) {
            formRef.current.requestSubmit();
        }
    }

    const [actionState, formAction, isPending] = useActionState(action, null);

    return (
        <>
            {actionState ? <h1 className="text-3xl font-bold">{actionState}</h1> : <h1 className="text-3xl font-bold">Choose a file...</h1>}
            {isPending && <h2 className="text-2xl font-bold">Uploading...</h2>}
            <form className="min-w-full mb-4" ref={formRef} action={formAction}>
                <input type="file" id="img" name="image" accept="image/*" onChange={handleFileChange} hidden disabled={isPending} />
                <label htmlFor="img" className={`block font-bold py-2 cursor-pointer text-center rounded-full shadow-md bg-red-200 ${isPending ? "bg-slate-800 opacity-50" : "hover:bg-red-300"}`}>{`Upload ${currentFileUrl && !isPending ? "Another" : ""} Image`}</label>
            </form>
        </>
    )
}