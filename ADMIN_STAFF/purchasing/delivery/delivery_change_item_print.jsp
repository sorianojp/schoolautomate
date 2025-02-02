<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.thinborderALL {
	border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function PageLoad(){
 	document.form_.req_no.focus();
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";	
	document.form_.change_item.value = "";	
	this.SubmitOnce('form_');
}
function PageAction(strAction){
    document.form_.printPage.value = "";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = strAction;
	document.form_.change_item.value = "1";
	this.SubmitOnce('form_');
}
function CancelClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.change_item.value = "";	
	this.SubmitOnce('form_');
}

function OpenSearchPO(){
	var pgLoc = "../purchase_order/purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ChangeItem(strItem,strParticular,strPrice,strPOItemIndex,strIsSupply,strItemFr,strQtyFr,strUnitFr,strUnitIndexFr){
	document.form_.change_item.value = "1";
	document.form_.item_name.value = strItem;
	document.form_.old_price.value = strPrice;
	document.form_.particular_old.value = strParticular;
	document.form_.po_item_index.value = strPOItemIndex;
	document.form_.is_supply.value = strIsSupply;
	document.form_.item_fr.value = strItemFr;
	document.form_.quantity_old.value = strQtyFr;
	document.form_.unit_old.value = strUnitFr;	
	document.form_.unit_index_fr.value = strUnitIndexFr;	
	this.SubmitOnce('form_');
}

function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
</script>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%

	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-DELIVERY-View delivery update Status","delivery_change_item.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Delivery DEL = new Delivery();	
	Vector vReqInfo = null;
	Vector vPOItemsRet = null;
	Vector vRetResult = null;
	Vector vChangeItem = null;
	int iCount = 1;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	

	if (WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);
		if(vReqInfo == null)
			strErrMsg = DEL.getErrMsg();
		else{
			if(WI.fillTextValue("pageAction").length() > 0){
				vRetResult = DEL.operateOnChangeItem(dbOP, request,
													  Integer.parseInt(WI.fillTextValue("pageAction")), (String)vReqInfo.elementAt(0));
				if(vRetResult == null)
					strErrMsg = DEL.getErrMsg();
				else
					strErrMsg = "Operation Successful";
			}
	
			vRetResult = DEL.operateOnReqItemsDel(dbOP,request,4,(String)vReqInfo.elementAt(0));
			if(vRetResult == null)
				strErrMsg = DEL.getErrMsg();
			else{
				vPOItemsRet = (Vector)vRetResult.elementAt(2);
				if (vPOItemsRet == null || vPOItemsRet.size() == 0)
					strErrMsg = "No Returned Items found";
			}
			vChangeItem = DEL.operateOnChangeItem(dbOP, request,4, (String)vReqInfo.elementAt(0));
		}
	}
%>	
<form name="form_" method="post" action="delivery_change_item_print.jsp">
  <%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div><br></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR PURCHASE ORDER NO. : <%=(String)vReqInfo.elementAt(1)%></strong></div></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>PO Status:</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(3))]%></strong></td>
      <td>PO Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="18" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(6))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(8))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(10)) == null){%>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>Office : </td>
      <td><strong><%=(String)vReqInfo.elementAt(11)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="18">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)+"/"+WI.getStrValue((String)vReqInfo.elementAt(11),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
  </table>
  <br>
  <%if((vChangeItem != null && vChangeItem.size() > 0)){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="11" class="thinborderALL"><div align="center"><font color="#000000"><strong>LIST 
          OF PO ITEM CHANGES</strong></font></div></td>
    </tr>
    <tr> 
      <td width="5%" class="thinborderBOTTOMLEFT"><div align="center"><strong>QTY</strong></div></td>
      <td width="5%" class="thinborderBOTTOMLEFT"><div align="center"><strong>UNIT</strong></div></td>
      <td width="8%" class="thinborderBOTTOMLEFT"><div align="center"><strong>ITEM (FROM)</strong></div></td>
      <td width="20%" class="thinborderBOTTOMLEFT"><div align="center"><strong>PARTICULARS 
          / DESCRIPTION (FROM)</strong></div></td>
      <td width="7%" class="thinborderBOTTOMLEFT"><div align="center"><strong>PRICE (FROM)</strong></div></td>
      <td width="6%" class="thinborderBOTTOMLEFT"><div align="center"><strong>QTY</strong></div></td>
      <td width="6%" class="thinborderBOTTOMLEFT"><strong>UNIT</strong></td>
      <td width="8%" class="thinborderBOTTOMLEFT"><strong>ITEM (TO)</strong></td>
      <td width="18%" height="25" class="thinborderBOTTOMLEFT"><div align="center"><strong>PARTICULARS 
          / DESCRIPTION (TO)</strong></div></td>
      <td width="7%" class="thinborderBOTTOMLEFT"><div align="center"><strong>PRICE(TO)</strong></div></td>
      <td width="10%" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><strong>REASON</strong></div></td>
    </tr>
    <%
	for(int iLoop = 0;iLoop < vChangeItem.size();iLoop+=16){%>
    <tr> 
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=(String)vChangeItem.elementAt(iLoop+7)%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+12)%></td>
      <td height="24" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+1)%></td>
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+2)%><%=WI.getStrValue((String)vChangeItem.elementAt(iLoop+14),"(",")","")%></td>
      <td class="thinborderBOTTOMLEFT"><div align="right">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat((String)vChangeItem.elementAt(iLoop+3),true),"")%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=(String)vChangeItem.elementAt(iLoop+9)%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+13)%></td>
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vChangeItem.elementAt(iLoop+4)%></td>
      <td class="thinborderBOTTOMLEFT"><div align="left">&nbsp; <%=(String)vChangeItem.elementAt(iLoop+5)%><%=WI.getStrValue((String)vChangeItem.elementAt(iLoop+15),"(",")","")%></div></td>
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vChangeItem.elementAt(iLoop+6),true),"")%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=WI.getStrValue((String)vChangeItem.elementAt(iLoop+11),"")%></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <%}// vReqInfo != null && vReqInfo.size()%>
  <!-- all hidden fields go here -->

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
