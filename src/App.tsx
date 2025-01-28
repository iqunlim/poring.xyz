import { useActionState, useRef, useState } from 'react'
import { getSignedS3Url, putSignedS3Object } from './Api'
import './App.css'

import Angeling from "./assets/angeling.gif"
import ArchAngeling from "./assets/arch.gif"
import Poring from "./assets/poring.gif"
import Poporing from "./assets/poporing-flip.gif"

import { FaClipboardList } from "react-icons/fa";


function App() {

  const [fileNameState, setFileNameState] = useState<string>("No file chosen");
  const [currentFileUrl, setCurrentFileUrl] = useState<string | undefined>();
  const [showPopup, setShowPopup] = useState(false);
  const [fadeOut, setFadeOut] = useState(false);
  const formRef = useRef<HTMLFormElement | null>(null);

  const action = async (_: string | null | undefined, formData: FormData) => {
    const file = formData.get("image") as File;
    if (file) {
      const SignedData = await getSignedS3Url(file);
      if (SignedData) {
        putSignedS3Object(file, SignedData, SignedData.url).then(() => {
          setFileNameState(file.name);
          setCurrentFileUrl(SignedData.imageUrl);
        })
        return "Uploaded"
      } else {
        return "There was an error. Please try again later"
      }
    } else {
      return "Please select a file"
    }
  }

  const [actionState, formAction, isPending] = useActionState(action, null);

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    event.preventDefault();
    if (event.target.files && event.target.files.length > 0 && formRef.current) {
      formRef.current.requestSubmit();
    }
  }

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
    <>
      <div className="container">
        <div className="container__form">
          {actionState ? <h2>{actionState}</h2> : <h1>Choose a file...</h1>}
          {isPending && <h2>Uploading...</h2>}
          <img className="mascot angel" src={Angeling}></img>
          <img className="mascot arch" src={ArchAngeling}></img>
          <form className="form" ref={formRef} action={formAction}>
            <div className="form__upload">
              <input type="file" id="img" name="image" accept="image/png, image/jpeg" onChange={handleFileChange} hidden disabled={isPending} />
              <label htmlFor="img" className={`form__uploadbutton ${isPending ? "faded" : ""}`}>{`Upload ${currentFileUrl && !isPending ? "Another" : ""} Image`}</label>
            </div>
          </form>
          {currentFileUrl && !isPending &&
            <div className="imgpreview">
              <span className="form__uploadchosen">{`Filename: ${fileNameState}`}</span>
              <div className="imgpreview__urlbox">
                {showPopup && <div
                  className={`popup ${fadeOut ? "fade-out" : ""}`}>
                  <p>Copied to clipboard!</p>
                </div>}
                <p>
                  <FaClipboardList onClick={() => handleClipboardClick(currentFileUrl)} style={{ cursor: "pointer" }} />
                  {currentFileUrl.replace(/^https?:\/\//, "")}</p>
              </div>
              <div className="image__actual">
                <img className="mascot poring" src={Poring} />
                <img className="mascot poporing" src={Poporing} />
                <img className="imgpreview__img" src={currentFileUrl} />
              </div>
            </div>}
        </div >
      </div >
    </>
  )
}

export default App
