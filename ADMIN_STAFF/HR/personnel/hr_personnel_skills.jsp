<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Applicant Personal Data</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
}

function viewInfo(){
	document.staff_profile.page_action.value = "3";
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	document.staff_profile.submit();
}

function EditRecord(){

	document.staff_profile.page_action.value="2";
	document.staff_profile.submit();
}

function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
}

function CancelRecord(index)
{
	location = "././hr_personnel_skills.jsp?applicant_="+document.staff_profile.applicant_.value+"&emp_id="+index+"&my_home=<%=WI.fillTextValue("my_home")%>";
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
<% if(WI.fillTextValue("my_home").compareTo("1") != 0){%>
	document.staff_profile.emp_id.focus();
<%}%>
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.staff_profile.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.staff_profile.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.staff_profile.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	//This page is called for applicant as well as for employees, -- do not show search button for applicant.
	boolean bolIsApplicant = false;
	if(WI.fillTextValue("applicant_").compareTo("1") ==0)
		bolIsApplicant = true;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Skills","hr_personnel_skills.jsp");

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
int iAccessLevel = -1;
if(WI.fillTextValue("applicant_").equals("1") ) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"HR Management","APPLICANTS DIRECTORY",request.getRemoteAddr(),
															"hr_personnel_skills.jsp");
}
else {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"HR Management","PERSONNEL",request.getRemoteAddr(),
															"hr_personnel_skills.jsp");
}											
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//
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

Vector vEmpRec = new Vector();
Vector vRetResult = new Vector();
boolean bNoError = false;
boolean bolNoRecord = false;
String strPrepareToEdit = null;
String strInfoIndex = WI.fillTextValue("info_index");

HRInfoLicenseETSkillTraining hrCon = new HRInfoLicenseETSkillTraining();

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));
strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}

if (strTemp.trim().length()> 0){

	
	if(bolIsApplicant){
		hr.HRApplNew hrApplNew = new hr.HRApplNew();
		vEmpRec = hrApplNew.operateOnApplication(dbOP, request,3);//view one
	}else{	
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
		if(vEmpRec == null || vEmpRec.size() ==0)
			strErrMsg = authentication.getErrMsg();
	}
	if (vEmpRec != null && vEmpRec.size() > 0)	{
		bNoError = true;
	}else{		
		bNoError = false;
	}
	
//	System.out.println(vEmpRec);
	
	if (bNoError) {
		if (iAction == 0 || iAction == 1 || iAction  == 2)
		vRetResult = hrCon.operateOnSkills(dbOP,request,iAction);

		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null){
					if(bolIsApplicant)
						strErrMsg = " Applicant skill record removed successfully.";
					else	
						strErrMsg = " Employee skill record removed successfully.";
				}
				else
					strErrMsg = hrCon.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null){
					if(bolIsApplicant)
						strErrMsg = " Applicant skill record added successfully.";
					else	
						strErrMsg = " Employee skill record added successfully.";
				}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					if(bolIsApplicant)
						strErrMsg = " Applicant skill record edited successfully.";
					else	
						strErrMsg = " Employee skill record edited successfully.";
					strPrepareToEdit = "0";
				}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
		} //end switch
	}// end bNoError
}

if (strPrepareToEdit.compareTo("1") == 0){
	vRetResult = hrCon.operateOnSkills(dbOP,request,3);

	bNoError = false;

	if (vRetResult != null && vRetResult.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = hrCon.getErrMsg();
	}
}

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");
	
	boolean bolAllowUpdate = false;
	if(strSchCode.startsWith("CIT"))
		bolAllowUpdate = true;
%>

<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_personnel_skills.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          SKILLS MAINTENANCE PAGE <%if(bolAUF){%>(SELF-ASSESSMENT) <%}%>::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="3" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="38%" height="25">&nbsp;&nbsp;
	  <%if(bolIsApplicant){%>
	  Applicant ID : <%}else{%>
	  Employee ID : <%}%><input name="emp_id" type= "text" class="textbox"   value="<%=WI.getStrValue(strTemp)%>"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      </td>
      <td width="7%" height="25">	  <%if(!bolIsApplicant){%>
	  <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
	  <%}%></td>
	<td width="55%"><input type="image" src="../../../images/form_proceed.gif" border="0"></a><label id="coa_info"></label></td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong> 
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>

  </table>
<%if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="105%"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
	<% if (!WI.fillTextValue("applicant_").equals("1")) {%>
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
              <%=WI.getStrValue(strTemp)%> <br> <br> 
              <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
              <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
            </td>
          </tr>
        </table>
	<%}else{%>
        <table width="400" height="77" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../faculty_img/"+WI.getStrValue(WI.fillTextValue("emp_id"), strTemp).toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
		      <%=strTemp%><br> <br> <br> <strong><%=WI.formatName((String)vEmpRec.elementAt(1),
			  								(String)vEmpRec.elementAt(2),
						 				    (String)vEmpRec.elementAt(3),4)%></strong><br>
              Position Applying for: <%=WI.getStrValue(vEmpRec.elementAt(11))%><br> 
              <%=WI.getStrValue(vEmpRec.elementAt(5),"<br>","")%> 
              <!-- email -->
              <%=WI.getStrValue(vEmpRec.elementAt(4))%> 
              <!-- contact number. -->
            </td>
          </tr>
        </table>
<% } // end if else applicant_
	String astrConvLevel[] = {"Beginner", "Intermediate","Advance","Expert"};
	strTemp = WI.fillTextValue("skill");
	strTemp2 = WI.fillTextValue("you");
	strTemp3 = WI.fillTextValue("level");
	if (bNoError && strPrepareToEdit.compareTo("1") == 0){
		strTemp =  (String) vRetResult.elementAt(0);
		strTemp2 = (String) vRetResult.elementAt(2);
		strTemp3 = (String) vRetResult.elementAt(3);
	}
%>
        <br>
        <table width="92%" border="0" align="center">
          <tr valign="bottom" >
            <td width="24%" height="22"><strong>SKILL NAME</strong></td>
            <td width="76%">&nbsp;</td>
          </tr>
          <tr >
            <td colspan="2" ><select name="skill">
                <option value="">Select Skill</option>
                <%=dbOP.loadCombo("SKILL_NAME_INDEX","SKILL_NAME"," FROM HR_PRELOAD_SKILL_NAME order by skill_name",strTemp,false)%>
              </select>
<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1){%>
			  <a href='javascript:viewList("HR_PRELOAD_SKILL_NAME","SKILL_NAME_INDEX","SKILL_NAME","SKILL NAME",
				"HR_INFO_SKILL,HR_APPL_INFO_SKILL","SKILL_NAME_INDEX, SKILL_NAME_INDEX", 
				" and HR_INFO_SKILL.is_del = 0, and HR_APPL_INFO_SKILL.is_del = 0","","skill")'><img border="0" src="../../../images/update.gif"></a> 
			               <font size="1">click to update skills</font> 		
<%}%>
			</td>
          </tr>
          <tr >
            <td ><strong>YEARS OF USE</strong></td>
            <td ><strong>LEVEL OF EXPERTISE</strong></td>
          </tr>
          <tr >
            <td ><input name="you" type="text" value="<%=WI.getStrValue(strTemp2,"")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyFloat('staff_profile','you')"  onBlur="style.backgroundColor='white';AllowOnlyFloat('staff_profile','you')" size="4" maxlength="3"></td>
            <td ><select name="level" id="select">
                <option value="">Select Level</option>
                <% strTemp3 = WI.getStrValue(strTemp3,"");
	if (strTemp3.compareTo("0") == 0) {%>
                <option value="0" selected>Beginner</option>
                <% }else {%>
                <option value="0" >Beginner</option>
                <%}if (strTemp3.compareTo("1") == 0) {%>
                <option value="1" selected>Intermediate</option>
                <% }else {%>
                <option value="1" >Intermediate</option>
                <%}if (strTemp3.compareTo("2") == 0) {%>
                <option value="2" selected>Advance</option>
                <% }else {%>
                <option value="2" >Advance</option>
                <%}if (strTemp3.compareTo("3") == 0) {%>
                <option value="3" selected>Expert</option>
                <% }else {%>
                <option value="3" >Expert</option>
                <%}%>
              </select></td>
          </tr>
          <tr>
            <td colspan="2"> <div align="center">
                <div align="center">
                  <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0 || !bNoError){%>
                  <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
                  <font size="1">click to save entries</font>
                  <%}else{ %>
                  <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
                  <font size="1">click to save changes</font><a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
                  to cancel and clear entries</font>
                  <%}}%>
                </div>
              </div></td>
          </tr>
        </table>
        <br>
<% vRetResult = hrCon.operateOnSkills(dbOP,request,4);
  if (vRetResult != null && vRetResult.size() > 0) { %>
        <table width="98%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinborder">
          <tr bgcolor="#666666">
            <td height="25" colspan="4" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST
                OF EMPLOYEE SKILLS</strong></font></div></td>
          </tr>
          <tr>
            <td width="37%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SKILLS
                NAME </strong></font></div></td>
            <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>YEARS OF
                USE </strong></font></div></td>
            <td class="thinborder"> <div align="center"><font size="1"><strong>LEVEL</strong></font></div></td>
            <td class="thinborder">&nbsp;</td>
          </tr>
<% for (int i=0; i < vRetResult.size() ; i +=5) { %>
          <tr>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+2))%></font></td>
            <td width="17%" class="thinborder">
			<%if(vRetResult.elementAt(i+3) == null) {%>
				&nbsp;
			<%}else{%>
				<font size="1"><%=astrConvLevel[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></font>
			<%}%>
			</td>
            <td width="22%" class="thinborder">
              <% if (iAccessLevel > 1) {%>
              <input name="image4" type="image" onClick='PrepareToEdit("<%=WI.getStrValue((String)vRetResult.elementAt(i+4))%>");' src="../../../images/edit.gif" width="40" height="26" border="0">
              <% if (iAccessLevel == 2) {%>
              <input name="image5" type="image" onClick='DeleteRecord("<%=WI.getStrValue((String)vRetResult.elementAt(i+4))%>");' src="../../../images/delete.gif" border="0">
              <%}}%>
              &nbsp;</td>
          </tr>
          <%} // end for loop %>
        </table>
<%} // end for listing table%>
      </td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

<input type="hidden" name="applicant_" value="<%=WI.fillTextValue("applicant_")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
