# 🕵️‍♂️ Hunt XSS Like a Pro  
**Automated Cross-Site Scripting (XSS) Scanner for Web Application Security Testing**

---

## 📦 Requirements

Make sure the following tools are installed and accessible from your `$PATH`:

- [`subfinder`](https://github.com/projectdiscovery/subfinder)  
  👉 `go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest`

- [`httpx-toolkit`](https://github.com/projectdiscovery/httpx)  
  👉 `sudo apt install httpx-toolkit`

- [`gau`](https://github.com/lc/gau)  
  👉 `go install github.com/lc/gau/v2/cmd/gau@latest`

- [`gf`](https://github.com/tomnomnom/gf)  
  👉 `go install github.com/tomnomnom/gf@latest`

- [`uro`](https://github.com/s0md3v/uro)  
  👉 `pip3 install uro`

- [`Gxss`](https://github.com/KathanP19/Gxss)  
  👉 `go install github.com/KathanP19/Gxss@latest`

- [`kxss`](https://github.com/Emoe/kxss)  
  👉 `go install github.com/Emoe/kxss@latest`

Ensure Go (`golang`) and Python (`pip3`) are installed for installing some of the above tools.

---

## 🚀 How It Works

This script automates the process of discovering potential XSS vulnerabilities by chaining together multiple powerful tools.

### 🔹 Step-by-step Workflow

1. **Subdomain Enumeration**  
   Uses `subfinder` to find subdomains (if a domain list is provided).

2. **Live Host Detection**  
   Uses `httpx-toolkit` to probe subdomains and detect active web servers.

3. **Passive URL Collection**  
   Uses `gau` to gather URLs from public sources like Wayback Machine and Common Crawl.

4. **XSS Filtering**  
   Pipes URLs through `gf xss`, `uro`, `Gxss`, and `kxss` to detect likely XSS injection points.

5. **Result Storage**  
   Outputs all findings into the `results/` directory.

---

## 🧰 Usage

```bash
git clone https://github.com/Astroo18/XSSRaptor.git
cd XSSRaptor
mkdir -p ~/.gf
mv .gf/* ~/.gf
chmod +x huntxss.sh
./huntxss.sh -dL domains.txt -o results -t 100 -v
