import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:manifest_mobile/model/review.dart';
import 'package:manifest_mobile/model/festival.dart';
import 'package:manifest_mobile/providers/festival_provider.dart';
import 'package:manifest_mobile/providers/review_provider.dart';
import 'package:manifest_mobile/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ReviewDetailsScreen extends StatefulWidget {
  final Review? review; // For viewing existing review
  final Festival? festival; // For creating new review
  final bool isNewReview;

  const ReviewDetailsScreen({
    super.key,
    this.review,
    this.festival,
    this.isNewReview = false,
  });

  @override
  State<ReviewDetailsScreen> createState() => _ReviewDetailsScreenState();
}

class _ReviewDetailsScreenState extends State<ReviewDetailsScreen> {
  late ReviewProvider reviewProvider;
  late FestivalProvider festivalProvider;
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  Festival? _festival; // ensure we can show details in both create/edit

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      festivalProvider = Provider.of<FestivalProvider>(context, listen: false);

      // If viewing existing review, populate the form
      if (widget.review != null) {
        setState(() {
          _rating = widget.review!.rating;
          _commentController.text = widget.review!.comment ?? '';
        });

        // Load festival for edit view (to show details)
        try {
          final fetched = await festivalProvider.getById(
            widget.review!.festivalId,
          );
          if (mounted) setState(() => _festival = fetched);
        } catch (_) {}
      } else if (widget.festival != null) {
        // Creating new review, ensure we have full festival with logo
        _festival = widget.festival;
        if ((_festival!.logo == null || _festival!.logo!.isEmpty)) {
          try {
            final fetched = await festivalProvider.getById(_festival!.id);
            if (mounted && fetched != null) setState(() => _festival = fetched);
          } catch (_) {}
        }
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a rating"),
          backgroundColor: Color(0xFF6A1B9A),
        ),
      );
      return;
    }

    if (UserProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not found"),
          backgroundColor: Color(0xFF6A1B9A),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var reviewData = {
        "festivalId": widget.festival?.id ?? widget.review!.festivalId,
        "userId": UserProvider.currentUser!.id,
        "rating": _rating,
        "comment": _commentController.text.trim(),
      };

      if (widget.review != null) {
        // Update existing review
        await reviewProvider.update(widget.review!.id, reviewData);
      } else {
        // Create new review
        await reviewProvider.insert(reviewData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.review != null
                ? "Review updated successfully"
                : "Review submitted successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: const Color(0xFF6A1B9A),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: const Color(0xFF6A1B9A),
              size: 43,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.review != null
              ? 'Edit your review'
              : 'Rate your festival experience',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1B69),
          ),
        ),
        const SizedBox(height: 24),
        _buildStarRating(),
        const SizedBox(height: 32),
        const Text(
          'Comment (optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1B69),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Share your festival experience...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF6A1B9A).withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF6A1B9A).withOpacity(0.3),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.review != null ? 'Update Review' : 'Submit Review',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use resolved festival if available; otherwise fallback to review's basic info
    final isEditing = widget.review != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.review != null ? 'Edit Review' : 'Write Review'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6A1B9A).withOpacity(0.1),
              const Color(0xFF6A1B9A).withOpacity(0.05),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Festival information (show on create and edit; fallback to review data)
              if (_festival != null || widget.review != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A1B9A).withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (() {
                                  final logo =
                                      _festival?.logo ??
                                      widget.review?.festivalLogo;
                                  if (logo != null && logo.isNotEmpty) {
                                    return Image.memory(
                                      base64Decode(logo),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.festival,
                                              size: 48,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            );
                                          },
                                    );
                                  }
                                  return Icon(
                                    Icons.festival,
                                    size: 48,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  );
                                })(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _festival?.title ??
                                        widget.review?.festivalTitle ??
                                        '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D1B69),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (_festival != null) ...[
                                    Text(
                                      _festival!.dateRange,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (_festival!.location != null)
                                      Text(
                                        _festival!.location!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (_festival != null || widget.review != null)
                const SizedBox(height: 24),

              // Review section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6A1B9A).withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildReviewForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
