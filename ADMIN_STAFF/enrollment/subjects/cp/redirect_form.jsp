<%@ page language="java" import="utility.*" %>
<%

DBOperation dbOP = null;
WebInterface WI = new WebInterface(request);


String strSubSecIndex = WI.fillTextValue("sub_sec_index");
String strCIndex = WI.fillTextValue("c_c_index");
String strDIndex = WI.fillTextValue("d_index");
String strCollegeName = WI.fillTextValue("college_name");
String strLblID = WI.fillTextValue("faculty_lbl_id");
String strDegreeType = null;
if(!strCIndex.equals("0"))
	strDIndex = "0";
if(!strDIndex.equals("0"))
	strCIndex = "0";


if(strCIndex.equals("0"))
	strCollegeName = "ALL";	

String strSYFrom = null;
String strSYTo = null;
String strSemester = null;
String strCourseIndex = null; 
String strMajorIndex = null;
String strYearLevel = "1";//this is not used in the page, but some method require this one, so i put default value
String strSubIndex = null;
String strSubName = null;

try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
boolean bolRedirect = false;
String strTemp = 
		" select offering_sy_from, offering_sy_to, offering_sem, e_sub_section.sub_index, sub_code, sub_name from e_sub_section "+
		" join subject on (subject.sub_index = e_sub_section.sub_index)"+
		" where is_child_offering = 0 and mix_sec_ref_index is null and  sub_sec_index = "+strSubSecIndex;	
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
if(rs.next()){
	strSYFrom   = rs.getString(1);
	strSYTo     = rs.getString(2);
	strSemester = rs.getString(3);
	strSubIndex = rs.getString(4);
	strSubName = rs.getString(5)+":::"+rs.getString(6);
	bolRedirect = true;
}else{rs.close();dbOP.cleanUP();%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Subject Information not found.</font></p>
<%return;}
rs.close();

String strCurrIndex = null;
strTemp = "select distinct cur_index from ENRL_FINAL_CUR_LIST where IS_VALID = 1 and IS_TEMP_STUD = 0 and SUB_SEC_INDEX = "+strSubSecIndex;

strCurrIndex = dbOP.getResultOfAQuery(strTemp, 0);

if(strCurrIndex == null || strCurrIndex.length()  == 0){
	strTemp = "select cur_index from e_sub_section where IS_VALID = 1 and SUB_SEC_INDEX = "+strSubSecIndex;
	strCurrIndex = dbOP.getResultOfAQuery(strTemp, 0);
}

if(strCurrIndex == null || strCurrIndex.length()  == 0)
	bolRedirect = false;
else{
	
	strTemp = "select degree_type from e_sub_section where sub_sec_index = "+strSubSecIndex;
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp == null)
		bolRedirect = false;
	else{
		if (strTemp.compareTo("1") == 0){
			strTemp = "select COURSE_INDEX, major_index from CCULUM_MASTERS where CUR_INDEX = "+strCurrIndex;
		}
		else if (strTemp.compareTo("2") == 0)
			strTemp = "select COURSE_INDEX,MAJOR_INDEX from cculum_medicine where CUR_INDEX = "+strCurrIndex;
		else
			strTemp = "select COURSE_INDEX,MAJOR_INDEX from CURRICULUM where CUR_INDEX = "+strCurrIndex;
			
		rs = dbOP.executeQuery(strTemp);
		if(rs.next()){
			strCourseIndex = rs.getString(1);
			strMajorIndex = rs.getString(2);
		}rs.close();
			
		if(strCourseIndex != null){
			strTemp = "select degree_type from COURSE_OFFERED where  course_index = "+strCourseIndex;			
			strDegreeType = dbOP.getResultOfAQuery(strTemp, 0);
		}		
	}	
}	

if(strCourseIndex == null)
	bolRedirect = false;

strMajorIndex = WI.getStrValue(strMajorIndex);

if(bolRedirect && strCourseIndex != null && strCourseIndex.length()  >0){
	dbOP.cleanUP();
	response.sendRedirect("../../faculty/enrollment_faculty_load_sched_redirect.jsp?course_index="+strCourseIndex+
		"&degreeType="+strDegreeType+
		"&school_year_fr="+strSYFrom+
		"&school_year_to="+strSYTo+
		"&semester="+strSemester+
		"&showList=1"+
		"&subject="+strSubIndex+
		"&year="+strYearLevel+
		"&sub_sec_index="+strSubSecIndex+
		"&subject_name="+strSubName+
		"&c_c_index="+strCIndex+
		"&d_index="+strDIndex+
		"&college_name="+strCollegeName+
		"&faculty_lbl_id="+strLblID+
		"&major_index="+strMajorIndex);
		
	return;
}else{%>
		
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Subject Information not found.</font></p>

<%}

dbOP.cleanUP();

%>