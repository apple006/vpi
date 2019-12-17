package press.whcj.ams.service;


import press.whcj.ams.entity.Project;
import press.whcj.ams.entity.dto.ProjectDto;
import press.whcj.ams.entity.vo.UserVo;

import java.util.List;

/**
 * @author xyyxhcj@qq.com
 * @since 2019/12/31
 */

public interface ProjectService {
	/**
	 * save
	 *
	 * @param projectDto projectDto
	 * @param operator operator
	 * @return id
	 */
	String save(ProjectDto projectDto, UserVo operator);

	/**
	 * assign
	 *
	 * @param projectDto projectDto
	 * @param operator   operator
	 */
	void assign(ProjectDto projectDto, UserVo operator);

	/**
	 * findList
	 *
	 * @param projectDto projectDto
	 * @param operator   operator
	 * @return List
	 */
	List<Project> findList(ProjectDto projectDto, UserVo operator);
}
