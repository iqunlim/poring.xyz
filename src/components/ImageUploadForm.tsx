import React, { useActionState, useEffect, useRef, useState } from "react";
import mime from "mime"; // TODO: Remove and replace with our own function

// A type to exclude the the properties of an input element that we have already set below and do not want changed
type OmittedProps = Omit<React.ComponentPropsWithoutRef<"input">, "onChange" | "hidden" | "type" | "id" | "name" | "disabled">

interface ImageUploadProps extends OmittedProps {
    formActionFunction: (state: Awaited<unknown | null | undefined>, payload: FormData) => string | Promise<string>,
    allowpaste?: boolean,
    autosubmit?: boolean,
}

/**
 * A (WIP) full featured Image Uploader button that includes listeners for drag and drop and clipboard paste with ctrl+v
 * Defaults to only accepting image files, pass in an accept prop to change this
 * @params formActionFunction: REQUIRED The action to use within the useActionState variable
 * @params paste: Enables using CTRL+V to paste files from the keyboard. Defaults to false
 * @params autosubmit: Automatically submits the form when a file is selected. If set to false, you must provide a submit button. Defaults to true
 */
export default function ImageUploadForm(props: ImageUploadProps, ...rest: OmittedProps[]) {

    /*TODOs:
    * Add support for multiple files
    */

    const { formActionFunction, style, allowpaste = false, autosubmit = true, accept = "images/*", children } = props;
    const [alreadyUploaded, setAlreadyUploaded] = useState(false); // A simple boolean to display "Another" on the button
    const [hovering, setHovering] = useState(false);
    const [actionState, formAction, isPending] = useActionState(formActionFunction, null); // React 19 form action function
    const formRef = useRef<HTMLFormElement | null>(null);
    const inputRef = useRef<HTMLInputElement | null>(null);

    console.debug("ImageUploadForm Rerendered")

    /* Drag and drop functionality Listeners */
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
                    addFileToInputElement(file, autosubmit);
                } catch (err) {
                    if (err instanceof Error) {
                        console.error("ImageUpload DnD: Drop Error", err.name, err.message);
                    }
                }
                return;
            }
        }
    }

    /* Handle when a file is selected in the input type=file element */
    const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        console.debug("ImageUpload Form: File change");
        event.preventDefault();
        if (event.target.files && event.target.files.length > 0 && formRef.current && autosubmit) {
            formRef.current.requestSubmit();
            setAlreadyUploaded(true);
        }
    }

    /**
     * A helper function to add files to the input element so that all functionality runs through the form Action
     * @param file The file to add
     * @param autoSubmit Whether or not to automatically submit the form, usually brought in from the parent component, defaults to false,
     */
    function addFileToInputElement(file: File, autoSubmit: boolean = false) {
        console.debug("ImageUpload Form: Adding file to form and submitting")
        const dataTransfer = new DataTransfer();
        dataTransfer.items.add(file);
        if (inputRef.current && formRef.current) {
            // Note: This does not fire off the onChange event in the input element
            inputRef.current.files = dataTransfer.files;
            // So we do have to manually request a submit
            if (autoSubmit) {
                formRef.current.requestSubmit();
                setAlreadyUploaded(true);
            }
        }
    }

    useEffect(() => {
        /* window CTRL+V functionality */
        const clipboardListener = async (e: KeyboardEvent) => {
            console.debug("ImageUpload Clipboard: Clipboard event");
            if (e.ctrlKey && e.key === "v") {
                try {
                    const clipboardItems = await navigator.clipboard.read();
                    for (const type of clipboardItems[0].types) {
                        if (type.match(/image\/\w+/i)) {
                            const blob = await clipboardItems[0].getType(type);
                            const fileName = window.crypto.randomUUID().slice(0, 8);
                            const extension = "." + mime.getExtension(blob.type);
                            const file = new File([blob], `${fileName}${extension}`, { type: blob.type });
                            // The form submit action controls the reactivity of the page
                            // forcing the input element to have a file in it and then
                            // submitting the form allows that interactivity to work even with ctrl+v
                            addFileToInputElement(file, autosubmit);
                            return;
                        }
                    }
                } catch (err) {
                    if (err instanceof Error) {
                        console.error("ImageUpload Clipboard Clipboard Event:", err.name, err.message);
                    }
                }
            }
        }
        if (allowpaste) {
            window.addEventListener('keydown', clipboardListener);
        }
        return () => {
            window.removeEventListener('keydown', clipboardListener);
        }
    }, [allowpaste, autosubmit]);

    return (
        <>
            <form
                onDragOver={dragOverListener}
                onDragLeave={dragLeaveListener}
                onDrop={dropListener}
                className="relative min-w-full mb-4" ref={formRef} action={formAction}>
                {/* Status updates */}
                {isPending && <h2 className="text-2xl font-bold">Uploading...</h2>}
                <h1 className="text-3xl font-bold">{actionState ? actionState : "Choose a file..."}</h1>
                {/* The input type=file is hidden and the label is styled with className */}
                <input {...rest} ref={inputRef} type="file" id="img" name="image" accept={accept} onChange={handleFileChange} hidden disabled={isPending} />
                <label style={style} htmlFor="img" className={`${props.className} ${isPending ? "bg-slate-800 hover:bg-slate-800 z-20 opacity-50" : ""}`}>{`Upload ${alreadyUploaded ? "Another" : ""} Image`}</label>
                {/* Visible drag and drop functionality */}
                {hovering &&
                    <>
                        {/* The first div is a full window darkening effect. The second div is the layed over box showing text */}
                        <div className="z-10 pointer-events-none fixed top-0 left-0 w-full h-full bg-slate-800 opacity-30"></div>
                        <div className="z-20 absolute pointer-events-none font-extrabold rounded-md top-0 left-0 
                        w-full h-full flex justify-center items-center bg-slate-200 opacity-70">
                            <h1 className="text-2xl">Drop image...</h1>
                        </div>

                    </>
                }
                {children}
            </form>
        </>
    )
}