import { useState } from "react";
import Mascot from "./components/Mascot";
import ImageUploadForm from "./components/ImageUploadButton";
import ClipboardButton from "./components/Clipboard";
import { ApiError, getSignedS3Url, putSignedS3Object } from "./Api";

function App() {

  const [fileUrls, setFileUrls] = useState<string[]>([]);

  /* This is the action that will be run with useActionState within the ImageUploadForm */
  const action = async (_: string | null | undefined, formData: FormData) => {
    const file = formData.get("image") as File;
    if (file) {
      try {
        const SignedData = await getSignedS3Url(file);
        if (SignedData && SignedData.url) {
          putSignedS3Object(file, SignedData, SignedData.url).then(() => {
            setFileUrls(prev => {
              if (SignedData.imageUrl) {
                return [SignedData.imageUrl, ...prev];
              }
              return prev
            }
            );
          })
          return "Uploaded";
        } else {
          return "There was an error. Please try again later";
        }
      } catch (error) {
        if (error instanceof ApiError) {
          console.error(error.name, error.toString());
        } else if (error instanceof Error) {
          console.error(error.name, error.message);
        }
        return "There was an error. Please try again later";
      }
    } else {
      return "Please select a file";
    }
  }

  return (
    <>
      <div className="flex flex-col h-screen items-center justify-center m-auto max-w-[40%]">
        <div className="big-shadow bg-white flex flex-col gap-4 items-center justify-center max-w-full min-w-[300px] px-2 py-4 relative rounded-sm">
          <Mascot type="angeling" className="right-[50px] top-[-45px]" />
          <Mascot type="archangeling" className="left-[50px] top-[-45px]" />
          <ImageUploadForm formActionFunction={action} />
          {/* When currentFileUrl set from the form, show all of the image information */}
          {fileUrls.length > 0 && (
            <>
              <div className="flex justify-center relative w-full">
                <Mascot type="poring" className="right-0 top-[-40px]" />
                <Mascot type="poporing" className="bottom-[-10px] left-0" />
                <img src={fileUrls[0]} className="max-h-[500px] object-contain" />
              </div>
              {fileUrls.map((url) => <ClipboardButton
                text={url}
                className="bg-red-200 cursor-copy flex gap-1 hover:bg-red-300 items-center no-scrollbar overflow-scroll p-1 relative rounded-md shadow-md text-nowrap w-full"
              />)}
            </>
          )}
        </div>
      </div>
    </>
  )
}

export default App
