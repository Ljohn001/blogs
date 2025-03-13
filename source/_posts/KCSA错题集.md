---
title: KCSA错题集
tags:
  - cncf
  - kubernetes
  - kcsa
categories:
  - kcsa
abbrlink: b6e3b579
---
### 前言

以下是学习KCSA练习题的错题集，很多题比较常见和容易理解出错，具体参考该项目：[https://kubernetes-security-kcsa-mock.vercel.app/](https://kubernetes-security-kcsa-mock.vercel.app/)

STRIDE 是一种常见的威胁建模框架，通常用于识别和应对系统中的安全风险。它由 **微软** 提出，涵盖了六类常见的威胁，每个字母代表一种不同类型的安全威胁。在 **云原生安全** 的上下文中，STRIDE 仍然适用，尤其是在容器化、微服务和分布式系统的设计和部署中。

**STRIDE** 框架的每个字母含义如下：

1. **S** -  **Spoofing** （欺骗）：指攻击者冒充合法用户或系统，从而绕过身份验证或授权机制。
   在云原生环境中，欺骗攻击可能会涉及伪造服务身份或通过滥用服务账户获取不应拥有的权限。
2. **T** -  **Tampering** （篡改）：指未授权的攻击者修改数据或系统配置。
   在云原生环境中，篡改攻击可能发生在容器、微服务通信或者数据存储层，攻击者通过修改配置文件或数据来破坏服务的完整性。
3. **R** -  **Repudiation** （否认）：指攻击者否认自己的行为，例如删除日志或修改日志文件，导致无法追踪攻击行为。
   在云原生环境中，服务或应用日志的缺乏审计或日志篡改可能导致安全事件的不可追踪。
4. **I** -  **Information Disclosure** （信息泄露）：指泄露敏感信息，导致机密数据被未经授权的用户访问。
   在云原生安全中，信息泄露可以通过错误的配置导致的暴露的环境变量、配置文件、数据库连接字符串等敏感信息。
5. **D** -  **Denial of Service (DoS)** （拒绝服务）：指通过使系统或网络无法响应合法请求来使系统瘫痪。
   在云原生环境中，DoS 攻击可能会通过资源耗尽（如 CPU 或内存）或网络攻击（如流量泛滥）使应用不可用。
6. **E** -  **Elevation of Privilege** （权限提升）：指攻击者通过漏洞或错误配置提升自己的权限，获得比预期更高的访问权限。
   在云原生环境中，攻击者可能会利用漏洞或误配置来从非管理员账户提升到管理员权限，从而操控整个系统或服务。

### What is the purpose of the 'namespaceSelector' in a NetworkPolicy?

Your answer: To select Pods in specific namespaces for ingress or egress rules

Correct answer: To select namespaces where the policy is applied

Explanation: The namespaceSelector applies the policy to all pods in the selected namespaces.

### In the context of STRIDE, what does 'Repudiation' refer to?

Your answer: Unauthorized access

Correct answer: Denial of an action or event

Explanation: Repudiation involves the ability to deny that an action occurred.

### Which annotation is used in a Pod manifest to specify an AppArmor profile for a container named 'nginx'?

Your answer: [apparmor.security.beta.kubernetes.io/nginx:](http://apparmor.security.beta.kubernetes.io/nginx:) 'localhost/nginx-profile'

Correct answer: [container.apparmor.security.beta.kubernetes.io/nginx:](http://container.apparmor.security.beta.kubernetes.io/nginx:) 'localhost/nginx-profile'

Explanation: The correct annotation is '[container.apparmor.security.beta.kubernetes.io/nginx:](http://container.apparmor.security.beta.kubernetes.io/nginx:) "localhost/nginx-profile"'.

### What could happen if you disable anonymous authentication on the kubelet?

Your answer: No effect; kubelet does not support anonymous access

Correct answer: Increased security by requiring authentication

Explanation: Disabling anonymous authentication ensures that only authenticated requests are accepted by the kubelet.

### Which of the following statements are true about gVisor and Firecracker? (Select all that apply)

Your answer: gVisor is a user-space kernel providing sandboxing, Firecracker is a container runtime interface, Firecracker uses lightweight microVMs with KVM

Correct answer: gVisor is a user-space kernel providing sandboxing, Firecracker uses lightweight microVMs with KVM, gVisor offers better performance than traditional VMs

Explanation: gVisor provides sandboxing; Firecracker uses microVMs; gVisor offers better performance than traditional VMs.

### Which of the following practices can help prevent container breakouts? (Select all that apply)

Your answer: Using minimal base images, Applying the principle of least privilege

Correct answer: Using minimal base images, Applying the principle of least privilege, Regularly updating container runtimes

### Which Kubernetes object is used to define a set of network access rules for pods?

Your answer: Service

Correct answer: NetworkPolicy

### Which of the following practices can help prevent container breakouts? (Select all that apply)

Your answer: Using minimal base images, Applying the principle of least privilege

Correct answer: Using minimal base images, Applying the principle of least privilege, Regularly updating container runtimes

### Which field in the Pod spec can you use to disable privilege escalation for all containers in the Pod?

Your answer: securityContext.allowPrivilegeEscalation: false

Correct answer: podSecurityContext.allowPrivilegeEscalation: false

Explanation: The correct field to disable privilege escalation for all containers in a Pod is 'spec.containers.securityContext.allowPrivilegeEscalation: false'. This must be set individually for each container within the Pod, as there is no global 'allowPrivilegeEscalation' setting at the Pod level.

### What could be a possible reason for failing to pull the latest version of an image from '[k8s.gcr.io](http://k8s.gcr.io)'?

Your answer: The image registry is deprecated

Correct answer: Incorrect image tag or name

### Which folders on a client machine are sensitive when accessing Kubernetes clusters? (Select all that apply)

Your answer: ~/.kube/config

Correct answer: ~/.kube/config, ~/.ssh/

### How can you improve kubelet security? (Select all that apply)

Your answer: Disable anonymous access, Use TLS certificates

Correct answer: Enable authentication and authorization, Disable anonymous access, Use TLS certificates

### What is the effect of applying a NetworkPolicy that selects no pods?

Your answer: It allows all traffic by default

Correct answer: It has no effect on the cluster

Explanation: A NetworkPolicy that selects no pods does nothing

## Which category of STRIDE is primarily concerned with integrity?

STRIDE 的哪个类别主要关注完整性？

A:Spoofing

Tampering

Repudiation

Information Disclosure

Denial of Service

## Which Kubernetes resource is used to assign permissions within a namespace to a user or group?

Your answer: Role

Correct answer: RoleBinding

Explanation: A RoleBinding grants the permissions defined in a Role within a namespace.

## What is the outcome of setting 'imagePullPolicy: Never' in a pod spec?

Your answer: The pod will ignore image updates in the registry

Correct answer: The pod will fail to start if the image is not present locally

Explanation: Setting 'imagePullPolicy: Never' prevents pulling images; the image must exist locally.

## Which Kubernetes resource is used to request persistent storage for a Pod?

Your answer: PersistentVolume

Correct answer: PersistentVolumeClaim

Explanation: A PersistentVolumeClaim requests storage resources provided by a PersistentVolume.

## Which compliance standard is particularly relevant for organisations in healthcare handling Protected Health Information (PHI)?

Your answer: HIPAA

Correct answer: HIPAA

Explanation: HIPAA contains security and privacy rules pertinent to PHI and is relevant when deploying healthcare solutions on Kubernetes.

## Which of the following are common CNI plugins that support Network Policies? (Select all that apply)

Your answer: Calico, Flannel, Weave Net, Cilium

Correct answer: Calico, Weave Net, AWS VPC CNI, Cilium

Explanation: Calico, Weave Net, Cilium, and AWS VPC CNI are CNI plugins that support Network Policies. Flannel does not support them by default. As of August 2023, AWS VPC CNI supports network policies but requires them to be enabled and does not support them for Fargate or Windows containers.

## Which field in the NetworkPolicy spec defines allowed egress destinations?

Your answer: to

Correct answer: egress

Explanation: The 'egress' field defines allowed egress rules.

## Which of the following are common security contexts applied at the Pod level? (Select all that apply)

Your answer: runAsUser, capabilities, privileged

Correct answer: runAsUser, fsGroup, seLinuxOptions

Explanation: These fields are commonly set at the Pod level for security.

## What is the MITRE ATT&CK framework, and how is it used in cybersecurity?

Your answer:

Correct answer: A knowledge base of adversary tactics and techniques used in cyberattacks

Explanation: The MITRE ATT&CK framework is a comprehensive knowledge base that catalogs adversary tactics, techniques, and procedures (TTPs) observed in real-world cyberattacks. It is widely used by cybersecurity professionals to understand attacker behavior, improve threat detection, and enhance defense strategies. Other options are incorrect because they describe unrelated tools or concepts.

## How can you update the image of a deployment without altering other configurations?

Your answer: Delete and recreate the deployment

Correct answer: Use 'kubectl set image' command

Explanation: This command updates the image without altering other configurations.

## Which of the following is a built-in Kubernetes authentication method that is NOT recommended for production use?

Your answer: OpenID Connect (OIDC)

Correct answer: Static Token File

Explanation: Static Token File authentication is not recommended for production.

## Which Kubernetes resource is used to request certificate signing via the Kubernetes API?

Your answer: Certificate

Correct answer: CertificateSigningRequest

Explanation: CertificateSigningRequest is used to request certificate signing.

## Which command lists all installed packages on a Debian-based system using apt?

Your answer: dpkg -l

Correct answer: apt list --installed

Explanation: The command 'apt list --installed' lists all packages installed via apt.

## Which field in the Pod spec can you use to disable privilege escalation for all containers in the Pod?

Your answer: spec.containers.securityContext.allowPrivilegeEscalation: false

Correct answer: podSecurityContext.allowPrivilegeEscalation: false

Explanation: The correct field to disable privilege escalation for all containers in a Pod is 'spec.containers.securityContext.allowPrivilegeEscalation: false'. This must be set individually for each container within the Pod, as there is no global 'allowPrivilegeEscalation' setting at the Pod level.

## Which command can you use to check the version of the kube-apiserver?

Your answer: 'kube-apiserver --version'

Correct answer: 'kubectl version'

Explanation: This command displays client and server Kubernetes versions.

## What is the primary purpose of a Cloud Workload Protection Platform (CWPP)?

Your answer: Provide identity and access management

Correct answer: Secure workloads across various environments

Explanation: CWPPs are designed to protect workloads in any environment.

## Which of the following are advantages of using a Service Mesh? (Select all that apply)

Your answer: Observability, Enhanced security with mutual TLS, Simplifies application code

Correct answer: Observability, Enhanced security with mutual TLS

Explanation: A Service Mesh improves observability and enhances security (for example, via mutual TLS).

## What was the precursor to the Pod Security Standards (PSS) in Kubernetes?

Your answer: Pod Security Admission (PSA)

Correct answer: PodSecurityPolicy (PSP)

Explanation: PSP was the precursor to PSS; it was deprecated and replaced by Pod Security Standards and the PodSecurity admission controller.

## Which security context setting ensures a container runs as a non-root user?

Your answer: readOnlyRootFilesystem: true

Correct answer: runAsNonRoot: true

Explanation: Setting 'runAsNonRoot: true' ensures the container is not run as root.

## Which field in the Pod spec is used to specify the container runtime class?

Your answer: runtimeClass

Correct answer: runtimeClassName

Explanation: The 'runtimeClassName' field specifies which RuntimeClass to use.

## Which NIST Special Publication provides guidelines on security and privacy controls for federal information systems?

Your answer: NIST SP 800-190

Correct answer: NIST SP 800-53 Rev. 5

## To enable audit logging in Kubernetes, which flag must be added to the API server configuration?

Your answer: --audit-policy-file

Correct answer: --audit-log-path

Explanation: The '--audit-log-path' flag enables audit logging by specifying the log file path.

## In a Pod spec, how do you specify that it should use the gVisor runtime class?

Your answer: Annotate the Pod with 'runtimeClass: gvisor'

Correct answer: Set 'runtimeClassName: "gvisor"' at the Pod spec level

Explanation: The 'runtimeClassName' field at the Pod spec level specifies which RuntimeClass to use.

## Which of the following is a common mitigation for 'Spoofing' threats?

Your answer: Using encryption for data at rest

Correct answer: Implementing proper authentication mechanisms

Explanation: Proper authentication helps verify identity and mitigate spoofing.

## Which Kubernetes feature allows for encryption of Secrets at rest?

Your answer: Using third-party encryption tools

Correct answer: Using etcd encryption provider

Explanation: Enabling etcd encryption at rest encrypts Secrets stored in etcd.

## Which command would you use to label a namespace 'production' with 'env=prod'?

Your answer: kubectl label namespaces env=prod production

Correct answer: kubectl label namespace production env=prod

Explanation: The correct command is 'kubectl label namespace production env=prod'.

## Which command can be used to set the default namespace for kubectl commands?

Your answer:

Correct answer: kubectl config set-context --current --namespace=`<namespace>`

Explanation: This command sets the default namespace in the current context.

## How do Network Policies work in Kubernetes?

Your answer: By default, they block all traffic between pods

Correct answer: They use iptables rules to control pod communication

Explanation: Network Policies are implemented via iptables rules by the network plugin.

## In Kubernetes, how can you apply an AppArmor profile to all containers within a Pod?

Your answer: Annotate each container with the AppArmor profile

Correct answer: Annotate each container with the AppArmor profile, Use the 'appArmorProfile' field in the container spec

## Which mitigation technique is suitable for 'Information Disclosure' threats?

Your answer: Using prepared SQL statements

Correct answer: Encrypting data at rest and in transit

Explanation: Encryption helps protect data confidentiality.

## Which of the following restrictions does the 'baseline' Pod Security Standard enforce? (Select all that apply)

Your answer: Disallows privileged containers, Blocks host networking and ports, Requires running as non-root

Correct answer: Disallows privileged containers, Blocks host networking and ports

## Which of the following are common CNI plugins that support Network Policies? (Select all that apply)

Your answer: Flannel, Calico, Weave Net, AWS VPC CNI, Cilium

Correct answer: Calico, Weave Net, AWS VPC CNI, Cilium

## Which object defines how to build and deploy an application from source code in Kubernetes?

Your answer: Deployment

Correct answer: BuildConfig

Explanation: While not a native Kubernetes object, BuildConfig is used in OpenShift for this purpose.

## Which authentication mechanisms are used by kubeadm? (Select all that apply)

Your answer: TLS certificates, Token-based authentication, OAuth tokens

Correct answer: TLS certificates, Token-based authentication

Explanation: kubeadm uses TLS certificates and token-based authentication mechanisms.

## Which of the following tools can be used for static analysis of Kubernetes manifests for security issues?

Your answer: kubectl describe

Correct answer: kubesec

Explanation: Kubesec is used for static analysis of manifests for security issues.

## How can you view the resources consumed by a pod?

Your answer: 'kubectl describe pod `<pod-name>`'

Correct answer: 'kubectl top pod `<pod-name>`'

Explanation: The 'kubectl top' command shows resource usage for pods or nodes.

## Which field in the Pod spec allows you to specify Linux capabilities for a container?

Your answer: securityContext.capabilities

Correct answer: container.securityContext.capabilities

Explanation: It is specified under the container's securityContext.

## Which Kubernetes resource can be used to manage policies with Open Policy Agent (OPA)?

Your answer: MutatingWebhookConfiguration

Correct answer: ValidatingWebhookConfiguration

Explanation: ValidatingWebhookConfiguration is used to integrate OPA for policy management.

## How do you specify in an audit policy to log events for all resources in a specific namespace?

Your answer: Specify 'namespaceSelector: {matchNames: ["`<namespace>`"]}'

Correct answer: Use 'namespaces: ["`<namespace>`"]' under the rule's 'namespaces' field

Explanation: The 'namespaces' field in the rule specifies which namespaces the rule applies to.

## Which Kubernetes admission controller runs first during the admission control process?

Your answer: ValidatingAdmissionWebhook

Correct answer: MutatingAdmissionWebhook

Explanation: The MutatingAdmissionWebhook runs first in the Kubernetes admission control process. This is because mutating admission controllers are designed to modify the incoming request before it is validated by validating admission controllers. Other options, such as ValidatingAdmissionWebhook, ResourceQuota, NamespaceLifecycle, and AlwaysPullImages, either run later in the process or serve different purposes

## Select all that apply: Which Kubernetes object(s) allow you to define a set of rules for validating or mutating admission requests?

Your answer: AdmissionController, CustomResourceDefinition

Correct answer: ValidatingWebhookConfiguration, MutatingWebhookConfiguration

Explanation: `ValidatingWebhookConfiguration` and `MutatingWebhookConfiguration` are used to integrate admission webhooks that validate or mutate admission requests. Option 2 (`AdmissionController`) is a general term for the mechanism but not a specific Kubernetes object. Option 3 (`CustomResourceDefinition`) is used to define custom resources, and Option 4 (`WebhookPolicy`) is not a valid Kubernetes object.

## Which of the following is a reason to use 'distroless' images?

Your answer: They have a larger attack surface

Correct answer: They are minimal images that reduce vulnerabilities

Explanation: Distroless images are minimal and reduce the attack surface by excluding unnecessary packages.

## Which NetworkPolicy policyTypes value is used to create a default deny egress policy?

Your answer: DenyAll

Correct answer: Egress

Explanation: Setting policyTypes to Egress with no egress rules creates a default deny egress policy.

## In managed Kubernetes services, who manages the etcd cluster?

Your answer: A third-party vendor manages etcd

Correct answer: The cloud provider manages etcd

Explanation: In managed services, etcd is managed by the provider.

## What is the default network policy behavior if no policies are applied?

Your answer: All egress traffic is denied; ingress is allowed

Correct answer: All ingress and egress traffic is allowed

Explanation: By default, Kubernetes allows all traffic if no Network Policies are applied.

## Which API server flag enables the ImagePolicyWebhook admission controller?

Your answer: --admission-control=ImagePolicyWebhook

Correct answer: --enable-admission-plugins=ImagePolicyWebhook

Explanation: The '--enable-admission-plugins=ImagePolicyWebhook' flag enables the ImagePolicyWebhook admission controller.

## Which tool can be used for real-time compliance monitoring and alerting in Kubernetes clusters?

Your answer: Kubernetes Dashboard

Correct answer: Sysdig Secure

Explanation: Sysdig Secure, like other tools, offers real-time compliance monitoring, anomaly detection, and security enforcement in Kubernetes

## Which Kubernetes resource is used to define permissions within a namespace?

Your answer: RoleBinding

Correct answer: Role

Explanation: A Role defines permissions within a namespace.

## Which combination of capabilities allows a compromised（被入侵） pod to access and modify the host? (Select all that apply)

Your answer: Running in privileged mode, Using host networking

Correct answer: Running in privileged mode, Mounting the host filesystem, Using host networking

Explanation: These capabilities allow a pod to access and modify the host.

## Which field in the Pod spec allows you to specify Linux capabilities for a container?

Your answer: podSecurityContext.capabilities

Correct answer: container.securityContext.capabilities

Explanation: It is specified under the container's securityContext.

## Which command enables audit logging by specifying the audit policy file in the API server configuration?

Your answer: --audit-log-path

Correct answer: --audit-policy-file

Explanation: The '--audit-policy-file' flag is used to point to the audit policy file.

## What does the 'kubectl config use-context' command do?

Your answer: Changes the current kubeconfig file

Correct answer: Sets the current context in kubeconfig

Explanation: This command switches the active context in your kubeconfig.

## Which admission controller should be used to enforce Pod Security Standards in Kubernetes 1.25 and above?

Your answer: PodSecurityPolicy

Correct answer: Pod Security Admission Controller

Explanation: The Pod Security Admission Controller is the recommended method in Kubernetes 1.25+.

## What measures can you take to prevent a container from running as the root user in Kubernetes?

Your answer: Modify the container image to exclude root user privileges

Correct answer: Use a Pod Security Policy or Pod Security Admission to enforce non-root user requirements

## **In managed Kubernetes services, who manages the etcd cluster?**

在托管的 Kubernetes 服务中，谁管理 etcd 集群？

Correct answer: The cloud provider manages etcd

## **Which field in the NetworkPolicy spec defines allowed egress destinations?**

Correct answer: egress

## **Does the underlying cloud infrastructure affect Kubernetes cluster security?**

底层云基础设施是否影响 Kubernetes 集群安全？

Correct answer: Yes, because infrastructure vulnerabilities can compromise the cluster
