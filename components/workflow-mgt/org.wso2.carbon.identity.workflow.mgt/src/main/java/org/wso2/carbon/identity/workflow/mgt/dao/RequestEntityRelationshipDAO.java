/*
 * Copyright (c) 2015, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.wso2.carbon.identity.workflow.mgt.dao;

import org.wso2.carbon.identity.base.IdentityException;
import org.wso2.carbon.identity.core.util.IdentityDatabaseUtil;
import org.wso2.carbon.identity.workflow.mgt.bean.Entity;
import org.wso2.carbon.identity.workflow.mgt.exception.InternalWorkflowException;
import org.wso2.carbon.identity.workflow.mgt.util.WorkflowRequestStatus;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class RequestEntityRelationshipDAO {

    /**
     * Add a new relationship between a workflow request and an entity.
     *
     * @param entity
     * @param uuid
     * @throws InternalWorkflowException
     */
    public void addRelationship(Entity entity, String uuid) throws InternalWorkflowException {

        Connection connection = null;
        PreparedStatement prepStmt = null;
        String query = SQLConstants.ADD_REQUEST_ENTITY_RELATIONSHIP;
        try {
            connection = IdentityDatabaseUtil.getDBConnection();
            prepStmt = connection.prepareStatement(query);
            prepStmt.setString(1, uuid);
            prepStmt.setString(2, entity.getEntityId());
            prepStmt.setString(3, entity.getEntityType());
            prepStmt.setInt(4, entity.getTenantId());
            prepStmt.executeUpdate();
            connection.commit();
        } catch (IdentityException e) {
            throw new InternalWorkflowException("Error when connecting to the Identity Database.", e);
        } catch (SQLException e) {
            throw new InternalWorkflowException("Error when executing the sql query", e);
        } finally {
            IdentityDatabaseUtil.closeAllConnections(connection, null, prepStmt);
        }
    }

    /**
     * Delete existing relationships of a request.
     *
     * @param uuid
     * @throws InternalWorkflowException
     */
    public void deleteRelationshipsOfRequest(String uuid) throws InternalWorkflowException {

        Connection connection = null;
        PreparedStatement prepStmt = null;
        String query = SQLConstants.DELETE_REQUEST_ENTITY_RELATIONSHIP;
        try {
            connection = IdentityDatabaseUtil.getDBConnection();
            prepStmt = connection.prepareStatement(query);
            prepStmt.setString(1, uuid);
            prepStmt.executeUpdate();
            connection.commit();
        } catch (IdentityException e) {
            throw new InternalWorkflowException("Error when connecting to the Identity Database.", e);
        } catch (SQLException e) {
            throw new InternalWorkflowException("Error when executing the sql query", e);
        } finally {
            IdentityDatabaseUtil.closeAllConnections(connection, null, prepStmt);
        }
    }

    /**
     * Check if a given entity has any pending workflow requests associated with it.
     *
     * @param entity
     * @return
     * @throws InternalWorkflowException
     */
    public boolean entityHasPendingWorkflows(Entity entity) throws InternalWorkflowException {

        Connection connection = null;
        PreparedStatement prepStmt = null;
        String query = SQLConstants.GET_PENDING_RELATIONSHIPS_OF_ENTITY;
        ResultSet resultSet;
        try {
            connection = IdentityDatabaseUtil.getDBConnection();
            prepStmt = connection.prepareStatement(query);
            prepStmt.setString(1, entity.getEntityType());
            prepStmt.setString(2, entity.getEntityId());
            prepStmt.setString(3, WorkflowRequestStatus.PENDING.toString());
            prepStmt.setInt(4, entity.getTenantId());
            resultSet = prepStmt.executeQuery();
            if (resultSet.next()) {
                return true;
            }
            connection.commit();
        } catch (IdentityException e) {
            throw new InternalWorkflowException("Error when connecting to the Identity Database.", e);
        } catch (SQLException e) {
            throw new InternalWorkflowException("Error when executing the sql query", e);
        } finally {
            IdentityDatabaseUtil.closeAllConnections(connection, null, prepStmt);
        }
        return false;
    }

    /**
     * Check if a given entity as any pending workflows of a given type associated with it.
     *
     * @param entity
     * @param requsetType
     * @return
     * @throws InternalWorkflowException
     */
    public boolean entityHasPendingWorkflowsOfType(Entity entity, String requsetType) throws
            InternalWorkflowException {

        Connection connection = null;
        PreparedStatement prepStmt = null;
        String query = SQLConstants.GET_PENDING_RELATIONSHIPS_OF_GIVEN_TYPE_FOR_ENTITY;
        ResultSet resultSet;
        try {
            connection = IdentityDatabaseUtil.getDBConnection();
            prepStmt = connection.prepareStatement(query);
            prepStmt.setString(1, entity.getEntityType());
            prepStmt.setString(2, entity.getEntityId());
            prepStmt.setString(3, WorkflowRequestStatus.PENDING.toString());
            prepStmt.setString(4, requsetType);
            prepStmt.setInt(5, entity.getTenantId());
            resultSet = prepStmt.executeQuery();
            if (resultSet.next()) {
                return true;
            }
            connection.commit();
        } catch (IdentityException e) {
            throw new InternalWorkflowException("Error when connecting to the Identity Database.", e);
        } catch (SQLException e) {
            throw new InternalWorkflowException("Error when executing the sql query", e);
        } finally {
            IdentityDatabaseUtil.closeAllConnections(connection, null, prepStmt);
        }
        return false;
    }

    /**
     * Check if there are any requests the associated with both entities.
     *
     * @param entity1
     * @param entity2
     * @return
     * @throws InternalWorkflowException
     */
    public boolean twoEntitiesAreRelated(Entity entity1, Entity entity2) throws InternalWorkflowException {

        Connection connection = null;
        PreparedStatement prepStmt = null;
        String query = SQLConstants.GET_REQUESTS_OF_TWO_ENTITIES;
        ResultSet resultSet;
        try {
            connection = IdentityDatabaseUtil.getDBConnection();
            prepStmt = connection.prepareStatement(query);
            prepStmt.setString(1, entity1.getEntityId());
            prepStmt.setString(2, entity1.getEntityType());
            prepStmt.setString(3, entity2.getEntityId());
            prepStmt.setString(4, entity2.getEntityType());
            prepStmt.setInt(5, entity1.getTenantId());
            prepStmt.setInt(6, entity2.getTenantId());
            resultSet = prepStmt.executeQuery();
            if (resultSet.next()) {
                return true;
            }
            connection.commit();
        } catch (IdentityException e) {
            throw new InternalWorkflowException("Error when connecting to the Identity Database.", e);
        } catch (SQLException e) {
            throw new InternalWorkflowException("Error when executing the sql query", e);
        } finally {
            IdentityDatabaseUtil.closeAllConnections(connection, null, prepStmt);
        }

        return false;
    }

}
