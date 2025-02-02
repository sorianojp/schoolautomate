<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoContact"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;	

String[] strColorScheme = CommonUtil.getColorScheme(5);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
	this.SubmitOnce("staff_profile");
}

function viewInfo(){
	document.staff_profile.page_action.value = "3";
	this.SubmitOnce("staff_profile");	
}
function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src="../../../images/blank.gif";
	this.SubmitOnce("staff_profile");
}

function EditRecord(){
	document.staff_profile.page_action.value="2";
	this.SubmitOnce("staff_profile");
}

function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");	
}

function CancelRecord(index)
{
	location = "./hr_personnel_contact_emr.jsp?emp_id="+index+"&my_home=<%=WI.fillTextValue("my_home")%>";
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
<% if (!bolMyHome){%>
	document.staff_profile.emp_id.focus();
<%}%>
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

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");

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
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_education.jsp");
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

Vector vEmpRec = null;
Vector vRetResult = null;
Vector vEditInfo = null;
boolean bNoError = false;
boolean bolNoRecord = false;
String strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
String strInfoIndex = WI.fillTextValue("info_index");
HRInfoContact hrCon = new HRInfoContact();

int iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));

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

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");


	if (vEmpRec != null && vEmpRec.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = "Employee has no profile.";
		bNoError = false;
	}

	if (bNoError) {
		if (iAction == 0 || iAction == 1 || iAction  == 2)
		vRetResult = hrCon.operateOnEmerAddress(dbOP,request,iAction);

		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null)
					strErrMsg = " Employee emergency contact information removed successfully.";
				else
					strErrMsg = hrCon.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null)
					strErrMsg = " Employee emergency contact information added successfully.";
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					strErrMsg = " Employee emergency contact information edited successfully.";
					strPrepareToEdit = "0";
				}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
		} //end switch
	}// end bNoError
}

if (strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = hrCon.operateOnEmerAddress(dbOP,request,3);
	if (vEditInfo == null || vEditInfo.size() == 0){
		if (strErrMsg == null) strErrMsg = hrCon.getErrMsg();
	}
}
vRetResult = hrCon.operateOnEmerAddress(dbOP,request,4);
if (vRetResult == null){
	if (strErrMsg == null) 
		strErrMsg = hrCon.getErrMsg();
}

boolean bolAllowUpdate = false;
if(strSchCode.startsWith("CIT"))
	bolAllowUpdate = true;
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_personnel_contact_emr.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          EMERGENCY CONTACT PAGE::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="28" colspan="3"><a href="hr_personnel_contact_main.jsp?my_home=<%=request.getParameter("my_home")%>"><img src="../../../images/go_back.gif" border="0"></a>&nbsp;
        <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
			</td>
      <td width="57%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
	   <label id="coa_info"></label>
		 </td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
<% 	if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="105%"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
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
        <br>
<%
	strTemp = WI.fillTextValue("cname");
	strTemp2 = WI.fillTextValue("relation");
	strTemp3 = WI.fillTextValue("mobileNo");

	if (vEditInfo != null){
		strTemp = (String)vEditInfo.elementAt(0);
		strTemp2 = (String)vEditInfo.elementAt(1);
		strTemp3 = (String)vEditInfo.elementAt(2);
	}
%>
		<table width="92%" border="0" cellpadding="4" cellspacing="0">
          <tr>
            <td width="9%">&nbsp;</td>
            <td width="22%">Name of Contact</td>
            <td width="69%"><input name="cname" type= "text" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="32"></td>
          </tr>
          <tr>
            <td width="9%">&nbsp;</td>
            <td>Relation</td>
            <td><select name="relation" id="relation">
<option value="">Select Relationship</option>
      <%=dbOP.loadCombo("RELATION_INDEX","RELATION_NAME"," FROM HR_PRELOAD_RELATION",strTemp2,false)%>
	  </select>
<%if((!bolMyHome || bolAllowUpdate)  && iAccessLevel > 1){%>
     <a href='javascript:viewList("HR_PRELOAD_RELATION","RELATION_INDEX","RELATION_NAME","RELATIONSHIP",
		"HR_INFO_DEPENDENT,HR_INFO_CON_EMER,HR_APPL_INFO_REFERENCE",
		"RELATION_INDEX, RELATION_INDEX,RELATION_INDEX", 
		" and HR_INFO_DEPENDENT.is_del = 0 and HR_INFO_DEPENDENT.is_valid = 1, " + 
		" and HR_INFO_CON_EMER.is_del = 0 and HR_INFO_CON_EMER.is_valid = 1,"  + 
		" and HR_APPL_INFO_REFERENCE.is_del = 0 and HR_APPL_INFO_REFERENCE.is_valid = 1"
,"","relation")'> <img src="../../../images/update.gif" border="0"></a>
      <font size="1">click to add/edit list of relationships</font>
<%}%>
	  		</td>
          </tr>
          <tr>
            <td width="9%">&nbsp;</td>
            <td>Contact #(mobile)</td>
            <td> <input name="mobileNo" type= "text" class="textbox"  value = "<%=WI.getStrValue(strTemp3)%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="mobileNo" size="16">
            </td>
          </tr>
<%
	strTemp = WI.fillTextValue("homeNo");
	strTemp2 = WI.fillTextValue("officeNo");
	strTemp3 = WI.fillTextValue("caddress");

	if (vEditInfo != null){
		strTemp = (String)vEditInfo.elementAt(3);
		strTemp2 = (String)vEditInfo.elementAt(4);
		strTemp3 = (String)vEditInfo.elementAt(5);
	}
%>
          <tr>
            <td width="9%">&nbsp;</td>
            <td>Contact #(home)</td>
            <td><input name="homeNo" type= "text" class="textbox"  value = "<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="homeNo" size="16">
              <font size="1">Format (country)(area) (tel.no.)</font></td>
          </tr>
          <tr>
            <td width="9%">&nbsp;</td>
            <td>Contact #(office)</td>
            <td><input name="officeNo" type= "text" class="textbox"  value = "<%=WI.getStrValue(strTemp2)%>"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="officeNo" size="16">
              <font size="1">Format (country)(area) (tel.no.)</font></td>
          </tr>
          <tr>
            <td width="9%">&nbsp;</td>
            <td valign="top">Contact Address</td>
            <td> <textarea name="caddress" cols="50" rows="2" id="caddress" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp3)%></textarea>
              </td>
          </tr>
          <tr>
            <td width="9%">&nbsp;</td>
            <td colspan="2"><div align="center">
                <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0 && bNoError){%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
                <font size="1">click to save entries</font>
                <%}else{ %>
                <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
                <font size="1">click to save changes</font><a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
                to cancel and clear entries</font>
                <%}}%>
              </div></td>
          </tr>
        </table>
        <br>
<%  if (vRetResult != null && vRetResult.size() > 0) {%>
        <table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" bgcolor="#000000">
          <tr bgcolor="#949E99"> 
            <td height="25" colspan="6"><div align="center"><strong><font color="#FFFFFF">LIST 
                OF EMPLOYEE'S CONTACT IN CASE OF EMERGENCY</font></strong></div></td>
          </tr>
          <tr align="center" bgcolor="#FFFFFF"> 
            <td width="24%" height="25"><strong>Name</strong></td>
            <td width="13%"><strong>Relation</strong></td>
            <td width="17%"><strong>Mobile #</strong></td>
            <td width="15%"><strong>Home #</strong></td>
            <td width="16%"><strong>Office #</strong></td>
            <td width="15%"><strong>Options</strong></td>
          </tr>
          <% for (int i=0; i < vRetResult.size() ; i+=8) {
	strTemp = (String) vRetResult.elementAt(i);
	strTemp2 = (String) vRetResult.elementAt(i+5);
	strTemp3 = (String) vRetResult.elementAt(i+1);
%>
          <tr bgcolor="#FFFFFF"> 
            <td height="25"><strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> </td>
            <td align="center"> <font size="1"><%=WI.getStrValue(strTemp3)%></font></td>
            <%
	strTemp = (String)vRetResult.elementAt(i+2);
	strTemp2 = (String)vRetResult.elementAt(i+3);
	strTemp3 = (String) vRetResult.elementAt(i+4);
%>
            <td align="center"><font size="1"><%=WI.getStrValue(strTemp)%></font></td>
            <td align="center"><font size="1"><%=WI.getStrValue(strTemp2)%></font></td>
            <td align="center"><font size="1"><%=WI.getStrValue(strTemp3)%></font></td>
            <td> <div align="center">
                <% if (iAccessLevel > 1)  {%>
                <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i+6)%>')"><img src="../../../images/edit.gif" width="40" height="26" border="0"> 
                </a> 
                <% if (iAccessLevel == 2) {%>
                <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i+6)%>');"><img src="../../../images/delete.gif" border="0" ></a> 
                <%}}else{%>
                N/A
                <%}%>
              </div></td>
          </tr>
          <% } // end for loop %>
        </table>
<% } // end vRetResult != null%>
        </td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
