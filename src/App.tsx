import { useState } from "react";
import Mascot from "./components/Mascot";
import ImageUploadForm from "./components/ImageUploadButton";
import ClipboardButton from "./components/Clipboard";

function App() {

  const [currentFileUrl, setCurrentFileUrl] = useState("");

  return (
    <>
      <div className="flex flex-col h-screen items-center justify-center m-auto max-w-[40%]">
        <div className="big-shadow bg-white flex flex-col gap-4 items-center justify-center max-w-full min-w-[300px] px-2 py-4 relative rounded-sm">
          <Mascot type="angeling" className="right-[50px] top-[-45px]" />
          <Mascot type="archangeling" className="left-[50px] top-[-45px]" />
          <ImageUploadForm currentFileUrl={currentFileUrl} currentFileSetter={setCurrentFileUrl} />
          {/* When currentFileUrl set from the form, show all of the image information */}
          {currentFileUrl && (
            <>
              <div className="flex justify-center relative w-full">
                <Mascot type="poring" className="right-0 top-[-40px]" />
                <Mascot type="poporing" className="bottom-[-10px] left-0" />
                <img src={currentFileUrl} className="max-h-[500px] object-contain" />
              </div>
              <ClipboardButton
                text={currentFileUrl}
                className="bg-red-200 cursor-copy flex gap-1 hover:bg-red-300 items-center no-scrollbar overflow-scroll p-1 relative rounded-md shadow-md text-nowrap w-full"
              />
            </>
          )}
        </div>
      </div>
    </>
  )
}

export default App
