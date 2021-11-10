#include "rzxpch.h"
#include "VKFence.h"

#include "Razix/Platform/API/Vulkan/VKDevice.h"
#include "Razix/Platform/API/Vulkan/VKUtilities.h"

namespace Razix {
    namespace Graphics {

        VKFence::VKFence(bool isSignalled /*= true*/)
            : m_IsSignaled(isSignalled)
        {
            VkFenceCreateInfo fenceCreateInfo = {};
            fenceCreateInfo.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
            fenceCreateInfo.flags = isSignalled ? VK_FENCE_CREATE_SIGNALED_BIT : 0;

            VK_CHECK_RESULT(vkCreateFence(VKDevice::Get().getDevice(), &fenceCreateInfo, nullptr, &m_Fence));
        }

        VKFence::~VKFence()
        {
            vkDestroyFence(VKDevice::Get().getDevice(), m_Fence, nullptr);
        }

        bool VKFence::isSignaled()
        {
            if (m_IsSignaled)
                return true;
            else {
                const VkResult result = vkGetFenceStatus(VKDevice::Get().getDevice(), m_Fence);
                if (result == VK_SUCCESS) {
                    m_IsSignaled = true;
                    return true;
                }
                return false;
            }
        }

        bool VKFence::wait()
        {
            RAZIX_CORE_ASSERT(!m_IsSignaled, "[Vulkan] Fence is Signaled!");

            // Waits until the fence is signaled
            const VkResult result = vkWaitForFences(VKDevice::Get().getDevice(), 1, &m_Fence, true, UINT32_MAX);

            VK_CHECK_RESULT(result);
            if (result == VK_SUCCESS) {
                m_IsSignaled = true;
                return false;
            }
            return true;
        }

        void VKFence::reset()
        {
            if (m_IsSignaled)
                VK_CHECK_RESULT(vkResetFences(VKDevice::Get().getDevice(), 1, &m_Fence));

            m_IsSignaled = false;
        }
    }
}