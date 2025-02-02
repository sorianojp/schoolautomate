<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	//strColorScheme is never null. it has value always.
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");
 %>
 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript">
function Convert() {
	var pgLoc =
	"../../../commfile/conversion.jsp?called_fr_form=staff_profile&cm_field_name=height&lb_field_name=weight";

	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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

function viewList(table,indexname,colname,labelname){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CancelRecord(strEmpID){
	location = "./hr_personnel_profiles.jsp";
}
function FocusID() {
	document.staff_profile.emp_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
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
Vector vRetResult = new Vector();
Vector vEmpRec = new Vector();
boolean bNoError = false;
boolean bolNoRecord = false;
String strInfoIndex = request.getParameter("info_index");

HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}

if (strTemp.length()> 0){

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");


	if (vEmpRec != null && vEmpRec.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = "Employee has no profile.";
		bNoError = false;
	}

	if (bNoError) {
		if (iAction == 1 || iAction  == 2 || iAction==3)
		vRetResult = hrPx.operateOnPersonalData(dbOP,request,iAction);

		switch(iAction){
			case 1:{ // add Record
				if (vRetResult != null)
					strErrMsg = " Employee personal record added successfully.";
				else
					strErrMsg = hrPx.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null)
					strErrMsg = " Employee personal record edited successfully.";
				else
					strErrMsg = hrPx.getErrMsg();
				break;
			}
			case 3:{ //  view record
				if (vRetResult != null)
					strErrMsg = hrPx.getErrMsg();
				break;
			}
		} //end switch
	}// end bNoError
}

if (vRetResult == null || vRetResult.size() < 1){
	bolNoRecord = true;
}

%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_personnel_profiles.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3"  bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          PERSONAL DATA ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" ></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
			</td>
      <td width="57%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
	   </td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
<%
	if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%" height="25"><hr size="1">
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
<table width="95%" border="0" align="center" cellpadding="4" cellspacing="0">
          <% strTemp = WI.fillTextValue("cstatus");
   strTemp2 = WI.fillTextValue("pob");
   strTemp3 = WI.fillTextValue("nationality");

   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(0));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(1));
		strTemp3 = WI.getStrValue((String)vRetResult.elementAt(2));
   }
%>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td width="18%">Civil Status</td>
            <td width="72%"> <select name="cstatus">
                <option value="1">Single</option>
                <% if (strTemp.compareTo("2") == 0) {%>
                <option value="2" selected>Married</option>
                <%}else{%>
                <option value="2">Married</option>
                <%} if (strTemp.compareTo("3") == 0) {%>
                <option value="3" selected>Divorced/Separated</option>
                <%}else{%>
                <option value="3" >Divorced/Separated</option>
                <%} if (strTemp.compareTo("4") == 0) {%>
                <option value="4" selected>Widow/Widower</option>
                <%}else{%>
                <option value="4" >Widow/Widower</option>
                <%}
			if(bolAUF){
				if (strTemp.compareTo("5") == 0) {%>
                <option value="5" selected>Annuled</option>
                <%}else{%>
                <option value="5">Annuled</option>
                <%} if (strTemp.compareTo("6") == 0) {%>
                <option value="6" selected>Living Together</option>
                <%}else{%>
                <option value="6">Living Together</option>
                <%}
			}%>
              </select> </td>
          </tr>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>Place of Birth</td>
            <td><input name="pob" value="<%=strTemp2%>" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="a_address222" size="48"></td>
          </tr>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>Nationality</td>
            <td><select name="nationality">
                <option value="">Select nationality</option>
                <%=dbOP.loadCombo("NATIONALITY_INDEX","NATIONALITY"," FROM HR_PRELOAD_NATIONALITY",strTemp3,false)%> </select> <a href='javascript:viewList("HR_PRELOAD_NATIONALITY","NATIONALITY_INDEX","NATIONALITY","NATIONALITY")'><img  border="0" src="../../../images/update.gif"></a> 
              <font size="1">click to add/edit list of nationality</font></td>
          </tr>
<% strTemp = WI.fillTextValue("religion");
   strTemp2 = WI.fillTextValue("sss");
   strTemp3 = WI.fillTextValue("tin");

   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(3));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(4));
		strTemp3 = WI.getStrValue((String)vRetResult.elementAt(5));
   }
%>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>Religion</td>
            <td><select name="religion">
                <option value="">Select Religion</option>
                <%=dbOP.loadCombo("RELIGION_INDEX","RELIGION"," FROM HR_PRELOAD_RELIGION",strTemp,false)%> </select> <a href='javascript:viewList("HR_PRELOAD_RELIGION","RELIGION_INDEX","RELIGION","RELIGION")'><img border="0" src="../../../images/update.gif"></a> 
              <font size="1">click to add/edit list of religion</font></td>
          </tr>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>SSS Number</td>
            <td><input name="sss" type= "text" value="<%=strTemp2%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="sss" size="16"></td>
          </tr>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>TIN </td>
            <td><input name="tin" type= "text" class="textbox"  value="<%=strTemp3%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="tin" size="16"></td>
          </tr>
<% strTemp = WI.fillTextValue("philhealth");
   strTemp2 = WI.fillTextValue("pag_ibig");
   strTemp3 = WI.fillTextValue("peraa");

   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(16));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(17));
		strTemp3 = WI.getStrValue((String)vRetResult.elementAt(18));
   }
%>
          <tr>
            <td>&nbsp;</td>
            <td>Philhealth</td>
            <td><input name="philhealth" type= "text" class="textbox"  value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="tin2" size="16"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Pag-ibig</td>
            <td><input name="pag_ibig" type= "text" class="textbox"  value="<%=strTemp2%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="tin3" size="16"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>PERAA</td>
            <td><input name="peraa" type= "text" class="textbox"  value="<%=strTemp3%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="tin4" size="16"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Tax Status</td>
            <td> <select name="tax_status">
                <option value="0">Zero (Z)</option>
                <%
   if (!bolNoRecord)
		strTemp = (String)vRetResult.elementAt(15);
	else
		strTemp = WI.fillTextValue("tax_status");
if(strTemp.compareTo("1") == 0){%>
                <option value="1" selected>Single(S)</option>
                <%}else{%>
                <option value="1">Single(S)</option>
                <%}if(strTemp.compareTo("2") == 0){%>
                <option value="2" selected>Head of Family (HF)</option>
                <%}else{%>
                <option value="2">Head of Family (HF)</option>
                <%}if(strTemp.compareTo("3") == 0) {%>
                <option value="3" selected>Married Employed (ME)</option>
                <%}else{%>
                <option value="3">Married Employed (ME)</option>
                <%}%>
              </select></td>
          </tr>
          <% strTemp = WI.fillTextValue("father");
   strTemp2 = WI.fillTextValue("f_occ");
   strTemp3 = WI.fillTextValue("mother");

   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(6));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(7));
		strTemp3 = WI.getStrValue((String)vRetResult.elementAt(8));
   }
%>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>Father's Name</td>
            <td><input name="father" type= "text" value ="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="father" size="32"></td>
          </tr>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>Occupation</td>
            <td><input name="f_occ" type= "text" value ="<%=strTemp2%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="f_occ" size="40"></td>
          </tr>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>Mother's Name</td>
            <td><input name="mother" type= "text" value ="<%=strTemp3%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="mother" size="32"></td>
          </tr>
          <% strTemp = WI.fillTextValue("m_occ");
   strTemp2 = WI.fillTextValue("height");
   strTemp3 = WI.fillTextValue("weight");

   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(9));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(10));
		strTemp3 = WI.getStrValue((String)vRetResult.elementAt(11));
   }
%>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>Occupation</td>
            <td><input name="m_occ" type= "text" value="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="m_occ" size="40"></td>
          </tr>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>Height (in cms)</td>
            <td><input name="height" type= "text" value="<%=strTemp2%>" onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="height" size="8"> 
              <font size="1">(1ft = 30.48cms)</font> <a href="javascript:Convert();">CLICK 
              FOR CONVERSION</a></td>
          </tr>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>Weight (in lbs)</td>
            <td><input name="weight" type= "text" value="<%=strTemp3%>" onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="weight" size="8"> 
              <font size="1">(1kg = 2.2lbs)</font></td>
          </tr>
          <%
   strTemp = WI.fillTextValue("blood");
   strTemp2 = WI.fillTextValue("rh");

   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(12));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(13));
   }
//System.out.println(strTemp);
%>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>Blood Type</td>
            <td><select name="blood" id="blood">
                <option value="">Not Known</option>
                <% if (strTemp.compareTo("1") == 0) {%>
                <option value="1" selected>A</option>
                <%}else{%>
                <option value="1" >A</option>
                <%}if (strTemp.compareTo("2") == 0) {%>
                <option value="2" selected >B</option>
                <%}else{%>
                <option value="2" >B</option>
                <%}if (strTemp.compareTo("3") == 0) {%>
                <option value="3" selected >AB</option>
                <%}else{%>
                <option value="3" >AB</option>
                <%}if (strTemp.compareTo("4") == 0) {%>
                <option value="4" selected>O</option>
                <%}else{%>
                <option value="4" >O</option>
                <%}%>
              </select> <select name="rh" id="rh">
                <option value="0">+</option>
                <% if (strTemp2.compareTo("1") == 0){%>
                <option value="1" selected>-</option>
                <%}else{%>
                <option value="1">-</option>
                <%}%>
              </select> </td>
          </tr>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td width="10%">&nbsp;</td>
            <td colspan="2"><div align="center"> 
                <% if (iAccessLevel > 1){
		if(bolNoRecord) {
%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                <font size="1">click to save entries</font> 
                <%}else{%>
                <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
                to save changes</font><a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
                to cancel and clear entries</font> 
                <%}}%>
              </div></td>
          </tr>
        </table>
<hr size="1"></td>
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
<%
   if (!bolNoRecord){
   		strInfoIndex = WI.getStrValue((String)vRetResult.elementAt(14));
   }
%>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
