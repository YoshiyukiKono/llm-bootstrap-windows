方向性は、大きく **3段階**あります。今の用途なら、いきなり大規模な文書処理基盤にせず、まず「OCRを独立RESTサービスとして追加する」のがよいと思います。

## 推奨する全体構成

```text
ユーザー / PowerShell / Open WebUI
                |
                v
        OCR Gateway / API
                |
        +-------+--------+
        |                |
        v                v
  OCRエンジン       文書解析エンジン
 PaddleOCR等       Docling等
        |
        v
構造化OCR結果
text / boxes / confidence / pages
        |
        v
Ollama
翻訳・要約・意味理解・整形
```

重要なのは、OCRとLLMの責務を分けることです。

* OCR：画像に何と書かれているか
* LLM：それをどう訳し、解釈し、整理するか

LLMに最初から両方やらせるより、再現性と検証可能性が高くなります。

## 方向性1：Tesseractを軽量OCRとして追加

最も小さく始める案です。

TesseractはオープンソースのOCRエンジンで、CLIまたはC/C++ APIとして利用できます。言語指定、ページ分割モード、テキストやPDFなどの出力に対応します。([GitHub][1])

構成例：

```text
Docker Desktop
├── open-webui
├── searxng
└── ocr-api
    ├── FastAPI
    └── Tesseract
```

APIは自作の薄いラッパーにします。

```http
POST /v1/ocr
Content-Type: multipart/form-data

file=<image>
languages=eng+jpn
```

返却例：

```json
{
  "text": "Purchase Order Receipt...",
  "language": ["eng", "jpn"],
  "pages": 1,
  "engine": "tesseract",
  "confidence": 0.91
}
```

### 長所

* CPUだけで動く
* 小さく、枯れている
* GPUをOllamaと競合しない
* スクリーンショットや整った文書なら十分
* WindowsネイティブでもDockerでも動かせる

### 弱点

* 複雑なレイアウト
* 表
* 縦書き
* 小さいUI文字
* 写真の中の文字
* 背景や装飾の多い画像

には弱めです。

したがって、**最初の実装確認用としては非常によいが、最終候補とは限らない**という位置づけです。

## 方向性2：PaddleOCRを本命OCRサービスにする

現時点で、この用途にはもっとも自然な本命です。

PaddleOCRはOCRだけでなく、文字検出、認識、向き補正、文書レイアウト解析などのパイプラインを持ち、セルフホスト型のサービス展開も公式に案内されています。基本Servingのほか、NVIDIA Tritonを利用する高安定Servingもあります。([PaddleOCR][2])

```text
Docker Desktop
├── open-webui
├── searxng
└── paddleocr
    ├── PaddleX serving
    ├── PP-OCR
    └── REST API
```

PaddleOCRのServingは、デバイスとしてGPUまたはCPUを選択できます。GPUが利用可能ならGPUを使う設定も可能です。([PaddlePaddle][3])

ただし、あなたのRTX 3060 6GBでは、OllamaとPaddleOCRが同時にGPUを取り合う可能性があります。そこで最初は、

```text
Ollama      → GPU
PaddleOCR   → CPU
```

が安全です。

OCR処理中だけOllamaモデルをアンロードする仕組みを作れば、後からPaddleOCRにもGPUを使わせられます。

### PaddleOCRの利点

* 日本語・英語の混在に向く
* 文字領域の座標を返せる
* 傾いた文字や複数領域に比較的強い
* 文書処理へ発展できる
* RESTサービス化の公式経路がある
* 将来、表やレイアウト解析へ拡張しやすい

この用途では、**Tesseractより一段本格的な標準OCRコンポーネント**として考えられます。

## 方向性3：Doclingを文書取り込みサービスとして追加

これはOCRそのものより、PDFやOffice文書をLLMで利用可能な形に変換する方向です。

Doclingは標準パイプラインとして、PDF解析、OCR、レイアウト認識、表認識を組み合わせられます。また、画像ページをVision Language Modelへ渡すVLMパイプラインも提供しています。([Docling Project][4])

```text
PDF / スキャン文書
        |
        v
      Docling
        |
        +-- Markdown
        +-- JSON
        +-- ページ構造
        +-- 表
        +-- 画像
        |
        v
      Ollama
```

これは、例えば以下の用途に向きます。

* 英語PDFを日本語化
* 技術資料をMarkdown化
* PDFを章・節構造付きで抽出
* 表を保持して読み込む
* 後でRAGに登録する
* PDF内の図と本文をまとめて理解する

Doclingは複数のOCRエンジンを切り替えられるため、OCRをその中の一工程として扱えます。単純なスクリーンショットにはやや重いですが、**文書処理基盤へ進む場合は有力**です。([Docling Project][4])

## あなたの用途に合う段階的な実装

私なら、次の順番にします。

### Phase 1：PaddleOCRの独立サービス

```text
llm-bootstrap-windows/
├── compose.yaml
├── services/
│   └── ocr-api/
│       ├── Dockerfile
│       ├── requirements.txt
│       └── app/
├── scripts/
│   ├── test-ocr.ps1
│   └── ocr-image.ps1
└── data/
    └── ocr/
```

操作例：

```powershell
.\scripts\ocr-image.ps1 `
  -Path .\samples\screen.png `
  -Language eng
```

出力：

```text
data/ocr/screen/
├── result.json
├── text.txt
└── overlay.png
```

`overlay.png` は検出した文字領域を枠で表示した画像です。これはOCR結果を人間が確認する際にかなり重要です。

### Phase 2：翻訳パイプライン

```powershell
.\scripts\translate-image.ps1 `
  -Path .\samples\screen.png `
  -Model qwen3:8b
```

内部処理：

```text
画像
 ↓
PaddleOCR
 ↓
英語テキスト＋座標＋信頼度
 ↓
Ollama
 ↓
日本語訳
```

結果：

```text
result/
├── source.txt
├── translation.ja.txt
├── ocr.json
└── overlay.png
```

ここで、OCRの誤読と翻訳の誤りを分離して確認できます。

### Phase 3：DoclingによるPDF処理

```powershell
.\scripts\translate-document.ps1 `
  -Path .\documents\manual.pdf
```

```text
PDF
 ↓
Docling
 ↓
構造付きMarkdown
 ↓
チャンク単位でOllama翻訳
 ↓
日本語Markdown
```

長文翻訳では、一括でLLMに渡すより、見出し・段落・表単位に分割する必要があります。

## API設計では汎用インターフェースにする

OCRエンジンを直接Open WebUIやPowerShellに結び付けない方がよいです。

例えば共通APIを定義します。

```http
POST /v1/ocr
POST /v1/documents/parse
POST /v1/translate/image
POST /v1/translate/document
```

OCR結果は、最低限この形式を持たせます。

```json
{
  "schema_version": "1.0",
  "engine": "paddleocr",
  "source": {
    "filename": "screen.png",
    "mime_type": "image/png"
  },
  "pages": [
    {
      "page_number": 1,
      "width": 1920,
      "height": 1080,
      "blocks": [
        {
          "text": "Purchase Order Receipt",
          "confidence": 0.98,
          "bbox": [120, 80, 570, 130],
          "language": "en"
        }
      ]
    }
  ]
}
```

こうしておけば、将来、

```text
PaddleOCR
Tesseract
クラウドOCR
Vision LLM
```

を差し替えたり比較したりできます。

## GPUの扱い

RTX 3060 6GBでは、OCRとLLMを同時にGPUへ常駐させる設計は避けた方がよいです。

推奨初期設定は：

| コンポーネント         | 実行先          |
| --------------- | ------------ |
| Ollama          | NVIDIA GPU   |
| Open WebUI      | CPU          |
| SearXNG         | CPU          |
| PaddleOCR       | CPU          |
| Docling標準パイプライン | CPU          |
| Vision LLM      | Ollama経由でGPU |

OCRの速度が問題になってから、

* PaddleOCRをGPU化
* Ollamaモデルを処理前にアンロード
* OCR処理後に再ロード
* OCR用とLLM用を排他的に実行

を検討すればよいです。

このPCでは並列化より、**GPUを一つの重い処理へ順番に割り当てる構成**の方が安定します。

## 結論

このリポジトリに最初に加えるなら、私は次を選びます。

```text
第一段階：
PaddleOCR CPU版
＋ FastAPIまたはPaddleX Serving
＋ PowerShellクライアント

第二段階：
OCR → Ollama翻訳のパイプライン

第三段階：
DoclingによるPDF・文書構造抽出
```

Tesseractは軽量なフォールバック、PaddleOCRは通常の画像OCR、DoclingはPDFなどの文書取り込み、と役割を分けるときれいです。

この方向へ進むなら、リポジトリ名の `llm-bootstrap-windows` はまだ妥当ですが、実態は次第に **local document intelligence workspace** に近づいていきます。今の段階では名前を変えず、`optional/ocr` または `profiles/document-intelligence` として追加するのがよさそうです。

[1]: https://github.com/tesseract-ocr/tessdoc?utm_source=chatgpt.com "GitHub - tesseract-ocr/tessdoc: Tesseract documentation · GitHub"
[2]: https://www.paddleocr.ai/main/en/version3.x/inference_deployment/serving/serving.html?utm_source=chatgpt.com "Self-hosted Serving - PaddleOCR Documentation"
[3]: https://paddlepaddle.github.io/PaddleOCR/main/en/version3.x/deployment/serving.html?utm_source=chatgpt.com "Sever Deployment - PaddleOCR Documentation"
[4]: https://docling-project.github.io/docling/examples/agent_skill/docling-document-intelligence/pipelines/?utm_source=chatgpt.com "Docling Pipelines Reference - Docling"
