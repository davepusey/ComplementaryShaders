// End Portal fix by fayer3#2332 (Modified)
if (blockEntityId == 200) {
    if (albedo.b < 10.1) {
        vec3[8] colors = vec3[](
            vec3(0.3472479, 0.6559956, 0.7387838) * 1.5,
            vec3(0.6010780, 0.7153565, 1.060625 ),
            vec3(0.4221090, 0.8135094, 0.9026056),
            vec3(0.3492291, 1.0241201, 1.8612821),
            vec3(0.7543085, 0.8238697, 0.6803233),
            vec3(0.4144472, 0.5648165, 0.8037   ),
            vec3(0.508905 , 0.6719649, 0.9982805),
            vec3(0.5361914, 0.8476583, 0.5008522));
        albedo.rgb = vec3(0.4214321, 0.4722309, 1.9922364) * 0.06;  

        float dither = Bayer64(gl_FragCoord.xy);
        #if AA > 1
            dither = fract(dither + frameTimeCounter * 16.0);
            int repeat = 4;
        #else
            int repeat = 8;
        #endif
        float dismult = 0.5;
        for (int j = 0; j < repeat; j++) {
            float add = float(j + dither) * 0.0625 / float(repeat);
            for (int i = 1; i <= 7; i++) {
                float colormult = 0.9/(30.0+i);
                float rotation = (i - 0.1 * i + 0.71 * i - 11 * i + 21) * 0.01 + i * 0.01;
                float Cos = cos(radians(rotation));
                float Sin = sin(radians(rotation));
                vec2 offset = vec2(0.0, 1.0/(3600.0/24.0)) * pow(16.0 - i, 2.0) * 0.004;

                vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos * (i * dismult + 1), 1.0)).xyz);
                if (abs(dot(normal, upVec)) > 0.9) {
                    wpos.xz /= wpos.y;
                    wpos.xz *= 0.06 * sign(- worldPos.y);
                    wpos.xz *= abs(worldPos.y) + i * dismult + add;
                    wpos.xz -= cameraPosition.xz * 0.05;
                } else {
                    vec3 absPos = abs(worldPos);
                    if (abs(dot(normal, eastVec)) > 0.9) {
                        wpos.xz = wpos.yz / wpos.x;
                        wpos.xz *= 0.06 * sign(- worldPos.x);
                        wpos.xz *= abs(worldPos.x) + i * dismult + add;
                        wpos.xz -= cameraPosition.yz * 0.05;
                    } else {
                        wpos.xz = wpos.yx / wpos.z;
                        wpos.xz *= 0.06 * sign(- worldPos.z);
                        wpos.xz *= abs(worldPos.z) + i * dismult + add;
                        wpos.xz -= cameraPosition.yx * 0.05;
                    }
                }
                vec2 pos = wpos.xz;

                vec2 wind = fract((frametime + 984.0) * (i + 8) * 0.125 * offset);
                vec2 coord = mat2(Cos, Sin, -Sin, Cos) * pos + wind;
                if (mod(float(i), 4) < 1.5) coord = coord.yx + vec2(-1.0, 1.0) * wind.y;
                
                vec3 psample = pow(texture2D(texture, coord).rgb, vec3(0.85)) * colors[i-1] * colormult;
                albedo.rgb += psample * length(psample.rgb) * (2048.0 / repeat);
            }
        }
    } else {
        albedo.rgb *= 2.2;
        emissive = 0.25;
    }
    quarterNdotU = 1.0;
}