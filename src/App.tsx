import { useState } from 'react'
import Mascot from "./components/Mascot"
import ImageUploadForm from './components/ImageUploadButton';
import ClipboardButton from './components/Clipboard';

function App() {

  const [currentFileUrl, setCurrentFileUrl] = useState("");

  return (
    <>
      <div className="flex flex-col justify-center items-center m-auto max-w-[40%] h-screen">
        <div className="min-w-[300px] max-w-full relative py-4 px-2 bg-white rounded-sm flex justify-center items-center flex-col gap-4 big-shadow">
          <Mascot className="top-[-45px] right-[50px]" type="angeling" />
          <Mascot className="top-[-45px] left-[50px]" type="archangeling" />
          <ImageUploadForm currentFileUrl={currentFileUrl} currentFileSetter={setCurrentFileUrl} />
          {/* When currentFileUrl set from the form, show all of the image information */}
          {currentFileUrl &&
            <>
              <div className="relative w-full flex justify-center">
                <Mascot className="top-[-40px] right-0" type="poring" />
                <Mascot className="bottom-[-10px] left-0" type="poporing" />
                <img className="max-h-[500px] object-contain" src={currentFileUrl} />
              </div>
              <ClipboardButton text={currentFileUrl} />
            </>}
        </div>
      </div >
    </>
  )
}

export default App
