import { useState } from "react";
import { FaClipboardList } from "react-icons/fa";
import Popup from "./Popup";

export default function ClipboardButton({ text, className }: { text: string, className: string }) {


    const [showPopup, setShowPopup] = useState(false);
    const [fadeOut, setFadeOut] = useState(false);

    const copyToClipboard = (text: string) => {
        navigator.clipboard.writeText(text).then(() => {
            console.log(`Text copied to clipboard: ${text}`);
        }).catch((err) => console.error(`Error copying text: ${text} error: ${err.message}`));
    }


    const handleClipboardClick = (text: string) => {
        if (!showPopup) {
            copyToClipboard(text);
            setShowPopup(true);
            setFadeOut(false);
            setTimeout(() => {
                setFadeOut(true);
                setTimeout(() => {
                    setShowPopup(false);
                }, 1000);
            }, 1000);
        }
    }

    return (
        <div onClick={() => handleClipboardClick(text)} className={className}>
            <Popup show={showPopup} fadeout={fadeOut} message="Copied to clipboard!" />
            <span>
                <FaClipboardList />
            </span>
            <span>
                {text.replace(/^https?:\/\//, "")}
            </span>
        </div>
    )
}