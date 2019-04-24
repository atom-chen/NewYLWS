/* Copyright © 2014 Apex Software. All rights reserved. */
namespace Apex.WorldGeometry
{
    using System;
    using Apex.Common;
    using Apex.Messages;
    using Apex.Services;
    using UnityEngine;

    /// <summary>
    /// Component for setting up <see cref="GridPortal" />s at design time.
    /// </summary>
    [AddComponentMenu("Apex/Navigation/Portals/Portal")]
    public class GridPortalComponent : ExtendedMonoBehaviour, IHandleMessage<GridStatusMessage>
    {
        /// <summary>
        /// The portal name
        /// </summary>
        public string portalName;

        /// <summary>
        /// The type of the portal, which determines how it affects path finding.
        /// </summary>
        public PortalType type;

        /// <summary>
        /// The bounds of the first portal
        /// </summary>
        public Bounds portalOne;

        /// <summary>
        /// The bounds of the second portal
        /// </summary>
        public Bounds portalTwo;

        /// <summary>
        /// The color to use when drawing portal gizmos.
        /// </summary>
        public Color portalColor = new Color(0f, 150f / 255f, 211f / 255f, 100f / 255f);

        [SerializeField, AttributeProperty]
        private int _exclusiveTo;
        private GridPortal _portal;
        private byte _activeGrids;

        /// <summary>
        /// Gets or sets the attribute mask that defines which units can use this portal.
        /// If set to a value other than <see cref="AttributeMask.None"/> only units with at least one of the specified attributes can use the portal.
        /// </summary>
        /// <value>
        /// The exclusive mask.
        /// </value>
        public AttributeMask exclusiveTo
        {
            get
            {
                return _exclusiveTo;
            }

            set
            {
                _exclusiveTo = value;
                if (_portal != null)
                {
                    _portal.exclusiveTo = value;
                }
            }
        }

        /// <summary>
        /// Creates a runtime Portal instance.
        /// </summary>
        /// <typeparam name="TAction">The type of the action.</typeparam>
        /// <param name="host">The host GameObject.</param>
        /// <param name="type">The portal type.</param>
        /// <param name="portalOne">The bounds of the first portal.</param>
        /// <param name="portalTwo">The bounds of the second portal.</param>
        /// <param name="action">The action.</param>
        /// <returns>The portal</returns>
        public static GridPortalComponent Create<TAction>(GameObject host, PortalType type, Bounds portalOne, Bounds portalTwo, out TAction action) where TAction : Component, IPortalAction
        {
            return Create<TAction>(host, type, portalOne, portalTwo, string.Empty, out action);
        }

        /// <summary>
        /// Creates a runtime Portal instance.
        /// </summary>
        /// <typeparam name="TAction">The type of the action.</typeparam>
        /// <param name="host">The host GameObject.</param>
        /// <param name="type">The portal type.</param>
        /// <param name="portalOne">The bounds of the first portal.</param>
        /// <param name="portalTwo">The bounds of the second portal.</param>
        /// <param name="portalName">Name of the portal.</param>
        /// <param name="action">The action.</param>
        /// <returns>The portal</returns>
        public static GridPortalComponent Create<TAction>(GameObject host, PortalType type, Bounds portalOne, Bounds portalTwo, string portalName, out TAction action) where TAction : Component, IPortalAction
        {
            action = host.AddComponent<TAction>();

            var p = host.AddComponent<RuntimeGridPortalComponent>();
            p.Configure(type, portalOne, portalTwo, portalName);

            return p;
        }

        /// <summary>
        /// Creates a runtime Portal instance.
        /// </summary>
        /// <typeparam name="TAction">The type of the action.</typeparam>
        /// <param name="host">The host GameObject.</param>
        /// <param name="type">The portal type.</param>
        /// <param name="portalOne">The bounds of the first portal.</param>
        /// <param name="portalTwo">The bounds of the second portal.</param>
        /// <returns>The portal</returns>
        public static GridPortalComponent Create<TAction>(GameObject host, PortalType type, Bounds portalOne, Bounds portalTwo) where TAction : Component, IPortalAction
        {
            return Create<TAction>(host, type, portalOne, portalTwo, string.Empty);
        }

        /// <summary>
        /// Creates a runtime Portal instance.
        /// </summary>
        /// <typeparam name="TAction">The type of the action.</typeparam>
        /// <param name="host">The host GameObject.</param>
        /// <param name="type">The portal type.</param>
        /// <param name="portalOne">The bounds of the first portal.</param>
        /// <param name="portalTwo">The bounds of the second portal.</param>
        /// <param name="portalName">Name of the portal.</param>
        /// <returns>The portal</returns>
        public static GridPortalComponent Create<TAction>(GameObject host, PortalType type, Bounds portalOne, Bounds portalTwo, string portalName) where TAction : Component, IPortalAction
        {
            host.AddComponent<TAction>();

            var p = host.AddComponent<RuntimeGridPortalComponent>();
            p.Configure(type, portalOne, portalTwo, portalName);

            return p;
        }

        /// <summary>
        /// Called on Awake
        /// </summary>
        protected virtual void Awake()
        {
            if (GridManager.instance.GetGrid(this.portalOne.center) != null)
            {
                _activeGrids++;
            }

            if (GridManager.instance.GetGrid(this.portalTwo.center) != null)
            {
                _activeGrids++;
            }

            if (_activeGrids == 2)
            {
                Initialize();
            }

            GameServices.messageBus.Subscribe(this);
        }

        /// <summary>
        /// Called on Start and OnEnable, but only one of the two, i.e. at startup it is only called once.
        /// </summary>
        protected override void OnStartAndEnable()
        {
            if (_portal != null)
            {
                _portal.enabled = true;
            }
        }

        private void OnDisable()
        {
            if (_portal != null)
            {
                _portal.enabled = false;
            }
        }

        private void OnDestroy()
        {
            GameServices.messageBus.Unsubscribe(this);
        }

        private void OnDrawGizmos()
        {
            Gizmos.color = this.portalColor;
            Gizmos.DrawCube(this.portalOne.center, this.portalOne.size);
            Gizmos.DrawCube(this.portalTwo.center, this.portalTwo.size);
        }

        private void Initialize()
        {
            var action = this.As<IPortalAction>();
            if (action == null)
            {
                var fact = this.As<IPortalActionFactory>();
                if (fact != null)
                {
                    action = fact.Create();
                }
            }

            if (action == null)
            {
                Debug.LogError("A portal must have an accompanying portal action component, please add one.");
                this.enabled = false;
                return;
            }

            try
            {
                _portal = GridPortal.Create(this.portalName, this.type, this.portalOne, this.portalTwo, this.exclusiveTo, action);
            }
            catch (Exception e)
            {
                Debug.LogError(e.Message);
                this.enabled = false;
            }
        }

        void IHandleMessage<GridStatusMessage>.Handle(GridStatusMessage message)
        {
            var gridBounds = message.gridBounds;
            if (gridBounds.Contains(this.portalOne.center) || gridBounds.Contains(this.portalTwo.center))
            {
                switch (message.status)
                {
                    case GridStatusMessage.StatusCode.DisableComplete:
                    {
                        _activeGrids--;
                        break;
                    }

                    case GridStatusMessage.StatusCode.InitializationComplete:
                    {
                        _activeGrids++;
                        break;
                    }
                }

                if (_activeGrids == 2)
                {
                    Initialize();

                    if (_portal != null)
                    {
                        _portal.enabled = this.enabled;
                    }
                }
                else if (_portal != null)
                {
                    GridManager.instance.UnregisterPortal(_portal.name);
                    _portal.enabled = false;
                    _portal = null;
                }
            }
        }

        private class RuntimeGridPortalComponent : GridPortalComponent
        {
            internal void Configure(PortalType type, Bounds portalOne, Bounds portalTwo, string portalName)
            {
                this.type = type;
                this.portalOne = portalOne;
                this.portalTwo = portalTwo;
                this.portalName = portalName;

                base.Awake();
                OnStartAndEnable();
            }

            protected override void Awake()
            {
                /* NOOP */
            }
        }
    }
}
