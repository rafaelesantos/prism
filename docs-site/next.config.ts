import type { NextConfig } from "next";
import createMDX from "@next/mdx";

const nextConfig: NextConfig = {
  pageExtensions: ["ts", "tsx", "md", "mdx"],
};

const withMDX = createMDX({
  options: {
    remarkPlugins: [require("remark-gfm")],
    rehypePlugins: [require("rehype-slug"), require("rehype-autolink-headings")],
  },
});

export default withMDX(nextConfig);