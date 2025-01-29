import React, { useActionState, useEffect, useRef, useState } from "react";
import mime from "mime";


interface ImageUploadProps extends React.PropsWithChildren {
    formActionFunction: (state: Awaited<unknown | null | undefined>, payload: FormData) => string | Promise<string>,
    className?: string,
    draganddrop?: boolean,
    paste?: boolean
}

/**
 * A (WIP) full featured Image Uploader button that includes listeners for drag and drop and clipboard paste with ctrl+v
 * @params formActionFunction: The action to use within the useActionState variable
 * @params dragonaddrop: Enables drag and drop functionality for (currently just image) files
 * @params paste: Enables using CTRL+V to paste files from the keyboard.
 */
export default function ImageUploadForm({ formActionFunction, className, draganddrop, paste, children }: ImageUploadProps) {

    /*TODOs:
    * Continue making more generic, currently only supports images
    * Properly support children elements. Currently they are just shoehorned in
    */
    const [alreadyUploaded, setAlreadyUploaded] = useState(false); // A simple boolean to display "Another" on the button
    const [hovering, setHovering] = useState(false); // File hover effect
    const [actionState, formAction, isPending] = useActionState(formActionFunction, null);
    const formRef = useRef<HTMLFormElement | null>(null);
    const inputRef = useRef<HTMLInputElement | null>(null);

    console.debug("ImageUploadForm Rerendered")

    const dragOverListener = (event: React.DragEvent<HTMLFormElement>) => {
        event.preventDefault();
        console.debug("ImageUpload DnD: Over drag and drop")
        setHovering(true);
    }

    const dragLeaveListener = (event: React.DragEvent<HTMLFormElement>) => {
        event.preventDefault();
        console.debug("ImageUpload DnD: Left drag and drop")
        setHovering(false);
    }

    const dropListener = (e: React.DragEvent<HTMLFormElement>) => {
        e.preventDefault();
        setHovering(false);
        console.debug("ImageUpload DnD: Drop")
        if (e?.dataTransfer?.items && e?.dataTransfer.items.length === 1) {
            const file = e.dataTransfer.items[0].getAsFile();
            if (file && file.type.match(/image\/\w+/i)) {
                try {
                    addFileToInputElementAndSubmit(file);
                } catch (err) {
                    if (err instanceof Error) {
                        console.error(err.name, err.message);
                    }
                }
                return;
            }
        }
    }

    /* handler to make the input button automatically submit when a file is selected */
    const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        console.debug("ImageUpload Form: File change");
        event.preventDefault();
        if (event.target.files && event.target.files.length > 0 && formRef.current) {
            try {
                formRef.current.requestSubmit();
                //setAlreadyUploaded(true);
            } catch (err) {
                console.error(err);
            }
        }
    }

    // Utility function to add file for event handlers
    function addFileToInputElementAndSubmit(file: File) {
        console.debug("ImageUpload Form: Adding file to form and submitting")
        const dataTransfer = new DataTransfer();
        dataTransfer.items.add(file);
        if (inputRef.current && formRef.current) {
            // Note: This does not fire off the onChange event in the input element
            inputRef.current.files = dataTransfer.files;
            // So we do have to manually request a submit
            formRef.current.requestSubmit();
            setAlreadyUploaded(true);
        }
    }

    useEffect(() => {
        /* window CTRL+V functionality */
        const clipboardListener = async (e: KeyboardEvent) => {
            console.debug("ImageUpload Clipboard: Clipboard event");
            if (e.ctrlKey && e.key === "v") {
                try {
                    const clipboardItems = await navigator.clipboard.read();
                    // We can get multiple items from the clipboard, but we only want the first one
                    for (const type of clipboardItems[0].types) {
                        // If it's an image...
                        if (type.match(/image\/\w+/i)) {
                            const blob = await clipboardItems[0].getType(type);
                            // Easy way to create random file names
                            const fileName = window.crypto.randomUUID().slice(0, 8);
                            const extension = "." + mime.getExtension(blob.type);
                            const file = new File([blob], `${fileName}${extension}`, { type: blob.type });
                            // The form submit action controls the reactivity of the page
                            // forcing the input element to have a file in it and then
                            // submitting the form allows that interactivity to work even with ctrl+v
                            addFileToInputElementAndSubmit(file);
                            return;
                        }
                    }
                } catch (err) {
                    if (err instanceof Error) {
                        console.error(err.name, err.message);
                    }
                }
            }
        }
        if (paste) {
            window.addEventListener('keydown', clipboardListener);
        }
        // Always make sure to return your cleanup!
        return () => {
            window.removeEventListener('keydown', clipboardListener);
        }
    }, [paste]);

    return (
        <>
            {/* The form code is to make the upload button just one button instead of the default input type=file behavior */}
            <form
                onDragOver={dragOverListener}
                onDragLeave={dragLeaveListener}
                onDrop={dropListener}
                className="relative min-w-full mb-4" ref={formRef} action={formAction}>
                <input ref={inputRef} type="file" id="img" name="image" accept="image/*" onChange={handleFileChange} hidden max={1} disabled={isPending} />
                <label htmlFor="img" className={`${className} ${isPending ? "bg-slate-800 hover:bg-slate-800 z-20 opacity-50" : ""}`}>{`Upload ${alreadyUploaded ? "Another" : ""} Image`}</label>
                {/* This is the drag and drop functionality */}
                {draganddrop && hovering &&
                    <>
                        {/* The first div is a full window darkening effect. The second div is the layed over box showing text */}
                        <div className="z-10 pointer-events-none fixed top-0 left-0 w-full h-full bg-slate-800 opacity-30"></div>
                        <div
                            className="z-20 absolute pointer-events-none font-extrabold rounded-md top-0 left-0 w-full h-full flex justify-center items-center bg-slate-200 opacity-70"><h1 className="text-2xl"
                            >Drop image...</h1></div>

                    </>
                }
                {children}
            </form>
            {/* Status updates */}
            {isPending && <h2 className="text-2xl font-bold">Uploading...</h2>}
            <h1 className="text-3xl font-bold">{actionState ? actionState : "Choose a file..."}</h1>
        </>
    )
}