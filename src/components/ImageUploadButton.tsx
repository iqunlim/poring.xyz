import React, { useActionState, useCallback, useEffect, useRef, useState } from "react";
import mime from "mime-types";


type ImageUploadProps = {
    // TODO: making this more generic, this function REQUIRES that it return strings
    formActionFunction: (state: Awaited<string | null | undefined>, payload: FormData) => string | Promise<string>,
    // className: string
    //target?: EventTarget OR should it be a Ref to an event target? what if its just passing in the window object???
    // draganddrop: boolean
    // paste: boolean
    // autosubmit: boolean
    // submitter: function that submits the form?
}

/**
 * A (WIP) full featured Image Uploader button that includes listeners for drag and drop and clipboard paste with ctrl+v
 * @params formActionFunction: The action to use within the useActionState variable
 */
export default function ImageUploadForm({ formActionFunction }: ImageUploadProps) {

    /*TODOs:
    * add state here called "draggedoverstate that changes the color of the button when you drag the file over the window"
    * Add in more props:
    *   className should be how its styled instead of hard-coding
    *       - Problem: isPending controls how it looks
    *   Add target for drag and drop
    *   Add toggles for drag and drop?
    *   Auto submit toggle? this might require an additional button...
    *   Element target for the event listener? That may not work with react components and may not be very react...
    * Make the form action more asyncronous? While fetch return "Uploading..." ?
    * The form action will need to be passed in and defined elsewhere if this component becomes more generic
    */
    const [alreadyUploaded, setAlreadyUploaded] = useState(false) // A simple boolean to display "Another" on the button
    const [actionState, formAction, isPending] = useActionState(formActionFunction, null);
    const formRef = useRef<HTMLFormElement | null>(null);
    const inputRef = useRef<HTMLInputElement | null>(null);

    /* window event listener functions */
    const clipboardListener = useCallback(async (e: KeyboardEvent) => {
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
                            addFileToInputElementAndSubmit(file)
                            return;
                        }
                    }
                }
            } catch (err) {
                if (err instanceof Error) {
                    console.error(err.name, err.message);
                }
            }
        }
    }, [])

    const dragOverListener = useCallback((e: DragEvent) => {
        e.preventDefault();
    }, [])

    const dropListener = useCallback((e: DragEvent) => {
        e.preventDefault();
        if (e?.dataTransfer?.items && e?.dataTransfer.items.length === 1) {
            const file = e.dataTransfer.items[0].getAsFile()
            if (file && file.type.match(/image\/\w+/i)) {
                addFileToInputElementAndSubmit(file)
                return;
            }
        } else {
            console.log("Please only drop one file and not multiple")
        }
    }, [])

    /* handler to make the input button automatically submit when a file is selected */
    const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        event.preventDefault();
        if (event.target.files && event.target.files.length > 0 && formRef.current) {
            try {
                formRef.current.requestSubmit();
                setAlreadyUploaded(true)
            } catch (err) {
                console.error(err)
            }
        }
    }

    // Utility function to add file for event handlers
    function addFileToInputElementAndSubmit(file: File) {
        const dataTransfer = new DataTransfer();
        dataTransfer.items.add(file);
        if (inputRef.current && formRef.current) {
            // Note: This does not fire off the onChange event in the input element
            inputRef.current.files = dataTransfer.files;
            // So we do have to manually request a submit
            try {
                formRef.current.requestSubmit();
                setAlreadyUploaded(true)
            } catch (err) {
                console.error(err)
            }
        }
    }

    /* Setting up the event listeners */
    useEffect(() => {
        window.addEventListener('keydown', clipboardListener)
        window.addEventListener('dragover', dragOverListener)
        window.addEventListener('drop', dropListener)
        // Always make sure to return your cleanup!
        return () => {
            window.removeEventListener('keydown', clipboardListener)
            window.removeEventListener('dragover', dragOverListener)
            window.removeEventListener('drop', dropListener)
        }
    }, [clipboardListener, dragOverListener, dropListener])

    return (
        <>
            <h1 className="text-3xl font-bold">{actionState ? actionState : "Choose a file..."}</h1>
            {isPending && <h2 className="text-2xl font-bold">Uploading...</h2>}
            {/* The form code is to make the upload button just one button instead of the default input type=file behavior */}
            <form className="min-w-full mb-4" ref={formRef} action={formAction}>
                <input ref={inputRef} type="file" id="img" name="image" accept="image/*" onChange={handleFileChange} hidden disabled={isPending} />
                <label htmlFor="img" className={`block font-bold py-2 cursor-pointer text-center rounded-full shadow-md bg-red-200 ${isPending ? "bg-slate-800 opacity-50" : "hover:bg-red-300"}`}>{`Upload ${alreadyUploaded ? "Another" : ""} Image`}</label>
            </form>
        </>
    )
}