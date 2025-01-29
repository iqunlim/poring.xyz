import Angeling from "../assets/angeling.gif";
import ArchAngeling from "../assets/arch.gif";
import Poring from "../assets/poring.gif";
import Poporing from "../assets/poporing-flip.gif";

type MascotType = "poring" | "poporing" | "angeling" | "archangeling";

interface MascotProps extends React.ComponentPropsWithoutRef<"img"> {
    className: string,
    type: MascotType
}

export default function Mascot({ type, className, ...rest }: MascotProps) {

    return <img {...rest}
        className={`absolute block object-fill h-16 ${className}`}
        src={typeToImg(type)} />
}

function typeToImg(type: MascotType) {
    switch (type) {
        case "poring":
            return Poring;
        case "poporing":
            return Poporing;
        case "angeling":
            return Angeling;
        case "archangeling":
            return ArchAngeling;
        default:
            throw new TypeError("TypeError: value was not in mascotType");
    }
}
