import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import HowItWorks from "@/components/HowItWorks";
import SafetySection from "@/components/SafetySection";
import FeedPreview from "@/components/FeedPreview";
import FinalCta from "@/components/FinalCta";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <div className="flex flex-1 flex-col">
      <Navbar />
      <main className="flex-1">
        <Hero />
        <HowItWorks />
        <FeedPreview />
        <SafetySection />
        <FinalCta />
      </main>
      <Footer />
    </div>
  );
}
