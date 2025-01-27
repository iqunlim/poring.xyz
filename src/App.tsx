import { useActionState, useRef, useState } from 'react'
import { getSignedS3Url, putSignedS3Object } from './Api'
import './App.css'



function App() {

  const [fileNameState, setFileNameState] = useState<string>("No file chosen")
  const [currentFileUrl, setCurrentFileUrl] = useState<string | undefined>();
  const formRef = useRef<HTMLFormElement | null>(null)

  const action = async (_: string | null | undefined, formData: FormData) => {
    const file = formData.get("image") as File
    if (file) {
      const SignedData = await getSignedS3Url(file)
      if (SignedData) {
        putSignedS3Object(file, SignedData, SignedData.url).then(() => {
          setFileNameState(file.name)
          setCurrentFileUrl(SignedData.imageUrl)
        })
        return "Uploaded."
      }
    }
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
      {currentFileUrl && <img style={{ maxWidth: "50%", maxHeight: "50%" }} src={currentFileUrl} />}
    </div>
  )
}

export default App
