<%@ page language="java" import="utility.*,java.util.Vector,hr.HRApplPersonalExtn"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Applicant's Data Card</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size:11px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head><script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function confirmApplicant() {
	if(document.form_.employee_id.value.length == 0 && !document.form_.new_.checked) {
		alert("Please enter employee ID.");
		return;
	}
	document.form_.page_action.value = "1";
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "./applicant_search_name.jsp?opner_info=form_.appl_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	document.form_.appl_id.focus();
}
///ajax here to load major..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		//alert(strURL);
		this.processRequest(strURL);
}
</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-APPLICANTS DIRECTORY-Personal Data","confirm_applicant.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>
		
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","APPLICANTS DIRECTORY",request.getRemoteAddr(), 
														"confirm_applicant.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult = null; Vector vTemp = null; String strTelNo = null;
Vector vApplicantInfo  = null;

hr.HRApplApplicationEval hrApplConfirm = new hr.HRApplApplicationEval();
hr.HRApplNew hrApplNew = new hr.HRApplNew();


strTemp = WI.fillTextValue("page_action"); boolean bolStop = false;
if(strTemp.length() > 0) {
	if(hrApplConfirm.convertApplicantToEmployee(dbOP, request)) {
		strErrMsg = "Applicant successfully moved to Employee database. Click on Assigned ID: <a href='../personnel/hr_personnel_personal_data.jsp?emp_id="+hrApplConfirm.getErrMsg()+"'>"+
		hrApplConfirm.getErrMsg()+"</a> to go to Profile page.";
		bolStop = true;
	}
	else	
		strErrMsg = hrApplConfirm.getErrMsg();
}

if(!bolStop) {
	strTemp = WI.fillTextValue("appl_id");
	if(strTemp.length() > 0){
		vApplicantInfo = hrApplNew.operateOnApplication(dbOP, request,3);//view one.
		if(vApplicantInfo == null)
			strErrMsg = hrApplNew.getErrMsg();
	}
	
	if (vApplicantInfo != null && vApplicantInfo.size() > 0){//proceed here. 
		vRetResult = hrApplConfirm.getApplicantDetailInfo(dbOP, strTemp);
		if(vRetResult == null) {
			strErrMsg = hrApplConfirm.getErrMsg();
			vApplicantInfo = null;
		}
	}
}//if already verified, I should not proceed. 
else	
	strTemp = WI.fillTextValue("appl_id"); 
		
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

%>


<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./confirm_applicant.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CONVERTING APPLICANT TO EMPLOYEE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr > 
      <td width="17%" height="28"><div align="right"><font size="1"><strong>&nbsp;&nbsp;</strong></font>Applicant's 
          ID :&nbsp;&nbsp;</div></td>
      <td width="18%"><input type="text" name="appl_id" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="18" value="<%=strTemp%>"> 
      </td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
      </td>
      <td width="60%"><input name="image" type="image" onClick="viewInfo();" src="../../../images/form_proceed.gif">
	  <font size="1" color="#0000FF">
	  	Note : Applicant with rejected status can't be converted to Employee.
	  </font>
	  </td>
    </tr>
  </table>
<%
if (vApplicantInfo != null && vApplicantInfo.size() > 0){//proceed here. %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"> 
        <table width="526" height="77" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../faculty_img/"+WI.fillTextValue("appl_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
              <%=strTemp%><br> <br> <br> <strong><%=WI.formatName((String)vApplicantInfo.elementAt(1),(String)vApplicantInfo.elementAt(2),
						 				 (String)vApplicantInfo.elementAt(3),4)%></strong><br>
              Position Applying for: <%=WI.getStrValue(vApplicantInfo.elementAt(11))%><br> 
              <%=WI.getStrValue(vApplicantInfo.elementAt(5),"<br>","")%> 
              <!-- email -->

              <%=WI.getStrValue(vApplicantInfo.elementAt(4))%> 
              <!-- contact number. -->            </td>
          </tr>
        </table></td>
      <td width="17%" rowspan="22"><img src="../../../images/sidebar.gif" width="11" height="270" align="right"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold">Employee ID </td>
      <td style="font-weight:bold; color:#0000FF"><input name="employee_id" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="32" value="<%=WI.fillTextValue("employee_id")%>">
	  &nbsp;&nbsp;
	  	  <input type="checkbox" name="new_" value="checked" <%=WI.fillTextValue("new_")%> onClick="document.staff_profile.submit();"> Auto create Employee ID (leave employee ID blank)
	  </td>
    </tr>
    <tr style="font-weight:bold">
      <td height="25">&nbsp;</td>
      <td>Date of Employment</td>
      <td>
		<%
			strTemp = WI.fillTextValue("doj");
			if(strTemp.length()  == 0) 
				strTemp = WI.getTodaysDate(1);
		%>
		  <input name="doj" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> &nbsp;
		  <a href="javascript:show_calendar('form_.doj');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Employee Name </td>
      <td style="font-size:9px;">
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(2);
else
	strTemp = WI.fillTextValue("fname");
%>
	  <input type="text" name="fname" value="<%=strTemp%>" class="textbox" size="18"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> (first)
	  &nbsp;&nbsp;&nbsp;
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(3);
else
	strTemp = WI.fillTextValue("mname");
%>
	  <input type="text" name="mname" value="<%=strTemp%>" class="textbox" size="12"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> (middle)
	  &nbsp;&nbsp;&nbsp;
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(4);
else
	strTemp = WI.fillTextValue("lname");
%>
	  <input type="text" name="lname" value="<%=strTemp%>" class="textbox" size="18"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> (last)	  </td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="15%">Gender</td>
      <td width="63%"> 
 <%
 if(vRetResult != null && vRetResult.size() > 0) {
 	strTelNo = (String)vRetResult.remove(5);
	vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
	vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
	
 	vTemp = (Vector)vRetResult.remove(0);
 }
 if(vTemp != null && vTemp.size() > 0) 
 	strTemp = (String)vTemp.elementAt(0);
 else
 	strTemp = WI.fillTextValue("gender");
%>
        <select name="gender">
          <option value="0">Male</option>
          <% if(strTemp.equals("1")) {%>
          <option value="1" selected>Female</option>
          <%}else{%>
          <option value="1">Female</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date of Birth </td>
      <td style="font-size:9px;">
<%
 if(vTemp != null && vTemp.size() > 0) 
 	strTemp = (String)vTemp.elementAt(5);
 else
 	strTemp = WI.fillTextValue("dob");
%>
	  <input name="dob" type="text" size="12" maxlength="12" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		 onKeyUp="AllowOnlyIntegerExtn('form_','dob','/');"> &nbsp;&nbsp;&nbsp;
		 <a href="javascript:show_calendar('form_.dob',
	  <%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        (mm/dd/yyyy)		 </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Contact Nos.</td>
      <td style="font-size:9px;">
<%
 if(strTelNo != null) 
 	strTemp = strTelNo;
 else
 	strTemp = WI.fillTextValue("tel_no");
%>
	  <input name="tel_no" type="text" size="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"><br>Address</td>
      <td style="font-size:9px;">
<%
 if(vTemp != null && vTemp.size() > 0) 
 	strTemp = (String)vTemp.elementAt(16);
 else
 	strTemp = WI.fillTextValue("address");
%>
	  <textarea name="address" cols="65" rows="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Employment Status </td>
      <td style="font-size:9px;">
<%
 	strTemp = WI.fillTextValue("pt_ft");
%>
	  <select name="pt_ft" >
			  <option value="1">Full Time </option>
			 <% if (strTemp.equals("0")){%>  				
			  <option value="0" selected>Part Time </option>	
			 <%}else{%> 
			  <option value="0">Part Time </option>
			 <%}%> 
            </select>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Emp. Type/Position</td>
      <td style="font-size:9px;">
<%
 	strTemp = WI.fillTextValue("emp_type");
%>
	  <select name="emp_type">
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp, false)%>
        </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Emp. Tenureship </td>
      <td style="font-size:9px;">
<%
 	strTemp = WI.fillTextValue("emp_status");
%>
	  <select name="emp_status">
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",strTemp, false)%>
        </select>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td style="font-size:9px;">
	  <select name="c_index" onChange="loadDept();">
                <option value="">N/A</option>
<% 
	strTemp = WI.fillTextValue("c_index");
%>
                <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Office/Department</td>
      <td style="font-size:9px;">
	  <label id="load_dept">
			 <select name="d_index">
			 
<% if(strTemp.length() > 0){%>
                <option value="">N/A</option>
<%
	strTemp = " and c_index = " +  strTemp;
} 
else	
	strTemp = " and (c_index = 0 or c_index is null) ";
%>
               <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",WI.fillTextValue("d_index"), false)%> </select>
						  </label>	  </td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1" color="blue"></td>
    </tr>
    <tr> 
      <td colspan="4" align="center" height="25"> 
        <% if (iAccessLevel > 1){%>
        <a href="javascript:confirmApplicant();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to create employee &nbsp; 
        <%}//iAccessLevel > 1%>      </td>
    </tr>
  </table>
 <%}//only if Applicant info is not null
 %> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>