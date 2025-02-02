<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoDependent"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function UpdateBenefit(strUserIndex, strDependentIndex) {
	var loadPg = "./hr_personnel_dep_benefit.jsp?user="+strUserIndex+"&dependent_index="+
		strDependentIndex+"&emp_id="+escape(document.form_.emp_id.value);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "1") {
		document.form_.hide_save.src = "../../../images/blank.gif";
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.consider_vedit.value = "1";//take edit info.
	document.form_.submit();
}
function focusID() {
	document.form_.emp_id.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
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
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;String strTemp3 = null;
	String strImgFileExt = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
		boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-dependent","hr_personnel_dependents.jsp");
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
														"hr_personnel_dependents.jsp");
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
Vector vRetResult = null;
Vector vEditInfo  = null;
Vector vEmpRec = null;

HRInfoDependent hrDep = new HRInfoDependent();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//add,edit,delete
	if(hrDep.operateOnDependent(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = hrDep.getErrMsg();
	else {	
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}
}
//System.out.println("Before 1 : "+strErrMsg);
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = hrDep.operateOnDependent(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = hrDep.getErrMsg();
}//System.out.println("Before 2 : "+strErrMsg);
//get the list. 
if(WI.fillTextValue("emp_id").length() > 0) {
	vRetResult = hrDep.operateOnDependent(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null ) 
		strErrMsg = hrDep.getErrMsg();
	//System.out.println(vRetResult);
}

strTemp = WI.fillTextValue("emp_id");

if (strTemp.trim().length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null || vEmpRec.size() == 0)
		strErrMsg = "Employee has no profile.";
}
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);
%>

<body bgcolor="#663300" onLoad="focusID();" class="bgDynamic">
<form action="./hr_personnel_dependents.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          DEPENDENTS DATA ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="30" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> 
      </td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top"> 
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
			</td>
      <td width="57%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
	   <label id="coa_info"></label></td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
<% if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
        <table width="400" border="0" align="center" cellpadding="0" cellspacing="1" bgcolor="#000000">
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
        <br> <table width="92%" border="0" align="center" cellpadding="4" cellspacing="0">
          <tr>
            <td width="7%">&nbsp;</td>
            <td width="20%">Name of Dependent</td>
            <td width="73%">
			<input name="dname" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
			onblur="style.backgroundColor='white'" size="32" value="<%=WI.fillTextValue("dname")%>"></td>
          </tr>
          <tr>
            <td width="7%">&nbsp;</td>
            <td>Date of Birth</td>
            <td><input name="dob" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("dob")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              <a href="javascript:show_calendar('form_.dob');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
          <tr>
            <td width="7%">&nbsp;</td>
            <td>Relationship</td>
            <td><select name="relation">
                <%=dbOP.loadCombo("RELATION_INDEX","RELATION_NAME"," FROM HR_PRELOAD_RELATION",WI.fillTextValue("relation"),false)%> 
              </select>
<%if(iAccessLevel > 1) {%>
              <a href='javascript:viewList("HR_PRELOAD_RELATION","RELATION_INDEX","RELATION_NAME","RELATIONSHIP");'> 
              <img src="../../../images/update.gif" border="0"></a>
<%}%>
			  </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>Eligibility</td>
            <td><select name="is_eligible">
                <option value="0">Not Eligible</option>
                <%
strTemp = WI.fillTextValue("is_eligible");
if(strTemp.compareTo("1") == 0)
{%>
                <option value="1" selected>Eligible</option>
                <%}else{%>
                <option value="1">Eligible</option>
                <%}%>
              </select></td>
          </tr>
          <tr>
            <td width="7%">&nbsp;</td>
            <td>Gender</td>
            <td>
			<select name="gender">
                <option value="0">Male</option>
<%
strTemp = WI.fillTextValue("gender");
if(strTemp.compareTo("1") == 0)
{%>
                <option value="1" selected>Female</option>
<%}else{%>
                <option value="1">Female</option>
<%}%>
              </select></td>
          </tr>
          <tr>
            <td width="7%">&nbsp;</td>
            <td colspan="2"> <div align="left">
                <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0){%>
                <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                <font size="1">click to save entries</font> 
                <%}else{ %>
                <a href='javascript:PageAction("","2");'><img src="../../../images/edit.gif" border="0"></a> 
                <font size="1">click to save changes</font> 
                <%}
}%>
                <a href="./sal_ben_incent_mgmt_incentives.jsp"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
                to cancel and clear entries</font> </div></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td colspan="2" valign="bottom"><div align="right"><img src="../../../images/print.gif"  border="0"><font size="1">click
                to print list of dependents</font></div></td>
          </tr>
        </table>
 <%boolean bolIsEligible = false;
 if (vRetResult != null && vRetResult.size() > 0) {%>
        <table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" bgcolor="#000000">
          <tr bgcolor="#666666"> 
            <td colspan="9"><div align="center"><strong><font color="#FFFFFF">LIST 
                OF EMPLOYEE'S DEPENDENTS</font></strong></div></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td width="20%"><font size="1"><strong>DEPENDENT NAME</strong></font></td>
            <td width="10%"><font size="1"><strong>DATE OF BIRTH</strong></font></td>
            <td width="5%"><strong><font size="1">AGE</font></strong></td>
            <td width="10%"><font size="1"><strong>RELATION</strong></font></td>
            <td width="5%"><font size="1"><strong>GENDER</strong></font></td>
            <td width="5%"><font size="1"><strong>ELIGIBILITY</strong></font></td>
            <td width="28%"><strong><font size="1">LIST OF BENEFIT</font></strong></td>
            <td width="8%"><font size="1"><b>ADD ELIGIBLE BENIFIT</b></font></td>
            <td width="7%"><font size="1"><b>DELETE</b></font></td>
          </tr>
<%  for (int i = 0; i < vRetResult.size(); i +=10){%>
          <tr bgcolor="#FFFFFF"> 
            <td><font size="1"><%=(String)vRetResult.elementAt(i + 1)%></font></td>
            <td> <div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></div></td>
            <td><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></div></td>
            <td><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></div></td>
            <td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
            <td align="center">
			<%if( ((String)vRetResult.elementAt(i + 6)).compareTo("1") ==0){%>
			<img src="../../../images/tick.gif"><%bolIsEligible=true;}else{bolIsEligible= false;%>
			<img src="../../../images/x.gif">
			<%}%></td>
            <td><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+8))%></font></td>
            <td><%if(bolIsEligible){%><a href='javascript:UpdateBenefit(<%=(String)vRetResult.elementAt(i + 9)%>,<%=(String)vRetResult.elementAt(i)%>);'>
			<img src="../../../images/update.gif" border="0"></a>
			<%}%>
			</td>
            <td>
              <% if (iAccessLevel == 2){%>
              <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'> 
              <img src="../../../images/delete.gif" border="0"></a>
              <%}%>
            </td>
          </tr>
          <% } // end for loop %>
        </table>
<%}%>
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
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="consider_vedit">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
