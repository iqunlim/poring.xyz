import { useState } from "react";
import Mascot from "./components/Mascot";
import FileUploadForm from "./components/FileUploadForm";
import ClipboardButton from "./components/Clipboard";
import { ApiError, putR2Object } from "./Api";
import { Analytics } from "@vercel/analytics/react";
import logo from "./assets/logo2.webp";

type fileData = {
  fileUrl: string;
  fileType: string;
};

function App() {
  const [fileData, setFileData] = useState<fileData[]>([]);
  /* This is the action that will be run with useActionState within the ImageUploadForm */
  const action = async (_: unknown, formData: FormData) => {
    const file = formData.get("image") as File;
    if (file) {
      try {
        const res = await putR2Object(file); // This feels hardcoded and should be more of an interface or injected
        if (res.error) {
          throw new ApiError(
            "putR2Object",
            "R2 Object Threw an error",
            res.error
          );
        } else {
          if (!res.fileUrl) {
            throw new ApiError(
              "putR2Object",
              "API did not return a file URL",
              res.fileUrl
            );
          }
          setFileData((prev) => [
            {
              fileUrl: res.fileUrl as string,
              fileType: file.type,
            },
            ...prev,
          ]);
        }
        return "Uploaded";
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
  };

  return (
    <main className="h-screen overflow-auto flex flex-col justify-center items-center">
      <div className="self-end px-4 pt-2">
        <img className="h-20 md:h-[100px]" src={logo} alt="poring.xyz" />
      </div>
      <Analytics />
      <div className="flex flex-col h-full items-center justify-center m-auto max-w-[40%]">
        <div className="big-shadow bg-white flex flex-col gap-4 items-center justify-center max-w-full min-w-[300px] px-2 py-4 relative rounded-sm">
          <Mascot type="angeling" className="right-[50px] top-[-45px]" />
          <Mascot type="archangeling" className="left-[50px] top-[-45px]" />
          <FileUploadForm
            className="relative flex justify-center align-center font-bold py-2 cursor-pointer text-center rounded-full shadow-md bg-red-300 hover:bg-red-400"
            formActionFunction={action}
            allowpaste
          />

          {/* Show image preview when its an image*/}
          {fileData.length > 0 &&
            fileData[0].fileType.match(/image\/\w+/i) !== null && (
              <div className="flex justify-center relative w-full">
                <Mascot type="poring" className="right-0 top-[-40px]" />
                <Mascot type="poporing" className="bottom-[-10px] left-0" />
                <img
                  src={fileData[0].fileUrl}
                  className="max-h-[500px] object-contain"
                />
              </div>
            )}

          {/* Copyable clipboard buttons */}
          {fileData.map((fileObj) => (
            <ClipboardButton
              key={fileObj.fileUrl}
              text={fileObj.fileUrl}
              className="bg-red-300 cursor-copy flex 
              gap-1 hover:bg-red-400 items-center no-scrollbar 
              overflow-scroll p-1 relative rounded-md shadow-md 
              text-nowrap w-full"
            />
          ))}
        </div>
      </div>
    </main>
  );
}

export default App;
