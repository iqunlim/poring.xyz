export default function Popup({ show, fadeout, message, className, ...rest }:
    { show: boolean, fadeout: boolean, message: string, className?: string }) {
    return (
        <>
            {show && <div {...rest}
                className={`${className ? className : ""} z-10 absolute bottom-0 left-0 transform-[translate(-50%, -50%)] bg-white rounded-sm transition-opacity duration-1000 ease-out ${fadeout ? "opacity-0" : ""}`}>
                <p className="m-0 px-2">{message}</p>
            </div>}
        </>
    )

}