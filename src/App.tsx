import { useActionState, useRef, useState } from 'react'
import { ApiResponse, getSignedS3Url, putSignedS3Object } from './Api'
import './App.css'



function App() {

  const [fileNameState, setFileNameState] = useState<string>("No file chosen")
  const [currentFileUrl, setCurrentFileUrl] = useState<string | undefined>();
  const formRef = useRef<HTMLFormElement | null>(null)

  const action = async (previousState: unknown, formData: FormData) => {
    console.log(previousState)
    const file = formData.get("image") as File
    if (file) {
      const SignedData = await getSignedS3Url(file)
      const S3Response = await SignedData.json();
      const ApiRes: ApiResponse = JSON.parse(S3Response)
      putSignedS3Object(file, ApiRes, ApiRes.data.url).then(() => {
        setFileNameState(file.name)
        setCurrentFileUrl(ApiRes.url)
      }
      )
      return "Uploaded."

    }
    return "Loading..."
  }

  const [actionState, formAction, isPending] = useActionState(action, null)

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files && event.target.files.length > 0 && formRef.current) {
      formRef.current.requestSubmit();
    }
  }

  return (
    <div className="container">
      {isPending ? "Loading..." : actionState}
      <form ref={formRef} action={formAction}>
        <div className="file-upload">
          <input type="file" id="img" name="image" accept="image/png, image/jpeg" onChange={handleFileChange} hidden />
          <label htmlFor="img" className="img-upload">Upload Image</label><span id="img-file-chosen">{fileNameState}</span>
        </div>
      </form>
      {currentFileUrl && <img src={currentFileUrl} />}
    </div>
  )
}

export default App
