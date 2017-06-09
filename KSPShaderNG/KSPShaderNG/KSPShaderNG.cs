using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

namespace KSPShaderNG
{
    // only start once at the MainMenu
    [KSPAddon(KSPAddon.Startup.MainMenu, true)]
    public class KSPShaderNG : MonoBehaviour
    {

        public Dictionary<string, Shader> allShaders = new Dictionary<string, Shader>();


        /// <summary>
        /// Initial Unity Awake call
        /// </summary>
        public void Awake()
        {
            Log.Normal("Loading Shaders");
            LoadShaders();

            var myshader = GetShader("ShaderNG/TypeC");

            if (myshader == null)
            {
                Log.Normal("Shader ShaderNG/TypeC was not loaded");
            } else
            {
                Log.Normal("Shader loaded normally");
            }

        }

        internal void LoadShaders()
        {
            Shader.WarmupAllShaders();
            foreach (var shader in Resources.FindObjectsOfTypeAll<Shader>())
            {
                if (!allShaders.ContainsKey(shader.name))
                {
                    allShaders.Add(shader.name, shader);
                    Log.Normal("got shader: " + shader.name);
                }
            }
        }

        internal Shader GetShader(string name)
        {
            if (allShaders.ContainsKey(name))
            {
                return allShaders[name];
            } else
            {
                return null;
            }
        }
    }
}
